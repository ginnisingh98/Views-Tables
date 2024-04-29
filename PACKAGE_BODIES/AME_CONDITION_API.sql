--------------------------------------------------------
--  DDL for Package Body AME_CONDITION_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_CONDITION_API" as
/* $Header: amconapi.pkb 120.0 2005/09/02 03:55 mbocutt noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'AME_CONDITION_API.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< IS_STRING_CONDITION >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to determine the attribute data type of a given
--   attribute, and hence the condition_type of a condition based on it. It
--   helps to establish whether the given condition is based on String
--   attributes or not. If attribute_id is not provided, then the condition_id
--   is used to first determine the attribute and then its type.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   p_effective_date
--   p_condition_id
--
-- Post Success:
--   The type of condition/attribute is determined.
--
-- Post Failure:
--   An application error is raised if the input parameters are invalid.
--   All Errors are propagated to the calling procedure.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal API Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
function is_string_condition(p_effective_date      in     date
                            ,p_condition_id        in     number   default null
                            )
return boolean is
  --
  -- Declare cursors and local variables
  --
  cursor csr_atr_type is
         select attribute_type
           from ame_attributes
          where p_effective_date between start_date
                  and nvl(end_date - ame_util.oneSecond, p_effective_date)
            and attribute_id in (select attribute_id
                                   from ame_conditions
                                  where condition_id = p_condition_id
                                    and p_effective_date between start_date and
                                          nvl(end_date - ame_util.oneSecond,
                                            p_effective_date)
                                );
  l_func                      varchar2(72) := g_package||'is_string_condition';
  l_atr_type                  varchar2(20);
  l_return_value              boolean;
  --
  begin
    hr_utility.set_location('Entering:'|| l_func, 10);
    l_return_value := false;
    if(p_condition_id is null) then
      hr_utility.set_location('Leaving:'|| l_func, 20);
      fnd_message.set_name('PER','AME_400494_INVALID_CONDITION');
      fnd_message.raise_error;
    else
      open csr_atr_type;
      fetch csr_atr_type into l_atr_type;
      if(csr_atr_type%found and l_atr_type = ame_util.stringAttributeType) then
        l_return_value := true;
      end if;
      close csr_atr_type;
    end if;
    hr_utility.set_location('Leaving:'|| l_func, 30);
    return l_return_value;
  end is_string_condition;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< CREATE_AME_CONDITION >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_ame_condition
  (p_validate               in     boolean  default false
  ,p_condition_key          in     varchar2
  ,p_condition_type         in     varchar2
  ,p_attribute_id           in     number   default null
  ,p_parameter_one          in     varchar2 default null
  ,p_parameter_two          in     varchar2 default null
  ,p_parameter_three        in     varchar2 default null
  ,p_include_upper_limit    in     varchar2 default null
  ,p_include_lower_limit    in     varchar2 default null
  ,p_string_value           in     varchar2 default null
  ,p_condition_id              out nocopy   number
  ,p_con_start_date            out nocopy   date
  ,p_con_end_date              out nocopy   date
  ,p_con_object_version_number out nocopy   number
  ,p_stv_start_date            out nocopy   date
  ,p_stv_end_date              out nocopy   date
  ,p_stv_object_version_number out nocopy   number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                      varchar2(72) := g_package||'create_ame_condition';
  l_swi_pkg_name              varchar2(72) := 'AME_CONDITION_SWI';
  l_condition_id              number;
  l_object_version_number     number;
  l_object_version_number_chd number;
  l_string_value              varchar2(4000);
  l_start_date                date;
  l_start_date_chd            date;
  l_end_date                  date;
  l_end_date_chd              date;
  l_isStringCondition         boolean;
  --
  begin
    hr_utility.set_location('Entering:'|| l_proc, 10);
    --
    -- Issue a savepoint
    --
    savepoint create_ame_condition;
    --
    -- Remember IN OUT parameter IN values. None here.
    --
    -- Call Before Process User Hook
    --
    begin
      ame_condition_bk1.create_ame_condition_b
                         (p_condition_key         => p_condition_key
                         ,p_condition_type        => p_condition_type
                         ,p_attribute_id          => p_attribute_id
                         ,p_parameter_one         => p_parameter_one
                         ,p_parameter_two         => p_parameter_two
                         ,p_parameter_three       => p_parameter_three
                         ,p_include_upper_limit   => p_include_upper_limit
                         ,p_include_lower_limit   => p_include_lower_limit
                         ,p_string_value          => p_string_value
                         );
    exception
      when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error
          (p_module_name => 'create_ame_condition'
          ,p_hook_type   => 'BP'
          );
    end;
    --
    -- Process Logic
    --
    ame_con_ins.ins(p_effective_date                => sysdate
                   ,p_condition_key                 => p_condition_key
                   ,p_condition_type                => p_condition_type
                   ,p_condition_id                  => l_condition_id
                   ,p_attribute_id                  => p_attribute_id
                   ,p_parameter_one                 => p_parameter_one
                   ,p_parameter_two                 => p_parameter_two
                   ,p_parameter_three               => p_parameter_three
                   ,p_include_lower_limit           => p_include_lower_limit
                   ,p_include_upper_limit           => p_include_upper_limit
                   ,p_security_group_id             => null
                   ,p_object_version_number         => l_object_version_number
                   ,p_start_date                    => l_start_date
                   ,p_end_date                      => l_end_date
                   );
    --
    -- If condition is based on string attributes and string_value is not empty,
    -- given that the call is NOT made through SWI package,call
    -- create_ame_string_value
    --
    if (instr(DBMS_UTILITY.FORMAT_CALL_STACK,
                l_swi_pkg_name||fnd_global.local_chr(10)) = 0) then
      l_isStringCondition := is_string_condition
                               (p_effective_date => sysdate
                               ,p_condition_id   => l_condition_id
                               );
      if(l_isStringCondition) then
        if(p_string_value is not null ) then
          --
          -- Insert the record.
          --
          create_ame_string_value
                  (p_validate                    => p_validate
                  ,p_condition_id                => l_condition_id
                  ,p_string_value                => p_string_value
                  ,p_object_version_number       => l_object_version_number_chd
                  ,p_start_date                  => l_start_date_chd
                  ,p_end_date                    => l_end_date_chd
                  );
        else
          --
          -- Raise an exception.Empty String Conditions cannot be created.
          --
          fnd_message.set_name('PER','AME_400525_STR_COND_EMPTY');
          fnd_message.raise_error;
        end if;
      else
        -- The condition is not based on string Attributes.
        -- Check for non empty String Value List and prompt the user
        if(p_string_value is not null ) then
          fnd_message.set_name('PER','AME_400495_STRVAL_NON_STR_CON');
          fnd_message.raise_error;
        end if;
      end if;
    end if;
    --
    -- Call After Process User Hook
    --
    begin
      ame_condition_bk1.create_ame_condition_a
                 (p_condition_key                 => p_condition_key
                 ,p_condition_type                => p_condition_type
                 ,p_attribute_id                  => p_attribute_id
                 ,p_parameter_one                 => p_parameter_one
                 ,p_parameter_two                 => p_parameter_two
                 ,p_parameter_three               => p_parameter_three
                 ,p_include_lower_limit           => p_include_lower_limit
                 ,p_include_upper_limit           => p_include_upper_limit
                 ,p_string_value                  => p_string_value
                 ,p_condition_id                  => l_condition_id
                 ,p_con_object_version_number     => l_object_version_number
                 ,p_con_start_date                => l_start_date
                 ,p_con_end_date                  => l_end_date
                 ,p_stv_object_version_number     => l_object_version_number_chd
                 ,p_stv_start_date                => l_start_date_chd
                 ,p_stv_end_date                  => l_end_date_chd
                 );
    exception
      when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error
           (p_module_name => 'create_ame_condition'
           ,p_hook_type   => 'AP'
           );
    end;
    --
    -- When in validation only mode raise the Validate_Enabled exception
    --
    if p_validate then
      raise hr_api.validate_enabled;
    end if;
    --
    -- Set all IN OUT and OUT parameters with out values
    --
    p_condition_id                  := l_condition_id;
    p_con_object_version_number     := l_object_version_number;
    p_con_start_date                := l_start_date;
    p_con_end_date                  := l_end_date;
    p_stv_object_version_number     := l_object_version_number_chd;
    p_stv_start_date                := l_start_date_chd;
    p_stv_end_date                  := l_end_date_chd;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 70);
  exception
    when hr_api.validate_enabled then
      --
      -- As the Validate_Enabled exception has been raised
      -- we must rollback to the savepoint
      --
      rollback to create_ame_condition;
      --
      -- Reset IN OUT parameters and set OUT parameters
      -- (Any key or derived arguments must be set to null
      -- when validation only mode is being used.)
      p_condition_id               := null;
      p_con_object_version_number  := null;
      p_con_start_date             := null;
      p_con_end_date               := null;
      p_stv_object_version_number  := null;
      p_stv_start_date             := null;
      p_stv_end_date               := null;

      --
      hr_utility.set_location(' Leaving:'||l_proc, 80);
    when others then
      --
      -- A validation or unexpected error has occured
      --
      rollback to create_ame_condition;
      --
      -- Reset IN OUT parameters and set all
      -- OUT parameters, including warnings, to null
      --
      p_condition_id               := null;
      p_con_object_version_number  := null;
      p_con_start_date             := null;
      p_con_end_date               := null;
      p_stv_object_version_number  := null;
      p_stv_start_date             := null;
      p_stv_end_date               := null;
      --
      hr_utility.set_location(' Leaving:'||l_proc, 90);
      raise;
  end create_ame_condition;
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< UPDATE_AME_CONDITION >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_ame_condition
  (p_validate                    in     boolean  default false
  ,p_condition_id                in     number
  ,p_parameter_one               in     varchar2 default hr_api.g_varchar2
  ,p_parameter_two               in     varchar2 default hr_api.g_varchar2
  ,p_parameter_three             in     varchar2 default hr_api.g_varchar2
  ,p_include_upper_limit         in     varchar2 default hr_api.g_varchar2
  ,p_include_lower_limit         in     varchar2 default hr_api.g_varchar2
  ,p_object_version_number       in out nocopy   number
  ,p_start_date                     out nocopy   date
  ,p_end_date                       out nocopy   date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                      varchar2(72) := g_package||'update_ame_condition';
  l_object_version_number     number;
  l_object_version_number_chd number := 1;
  l_condition_id              number;
  l_start_date                date;
  l_start_date_chd            date;
  l_end_date                  date;
  l_end_date_chd              date;
  l_string_value              varchar2(4000);
  --
  begin
    hr_utility.set_location('Entering:'|| l_proc, 10);
    --
    -- Issue a savepoint
    --
    savepoint update_ame_condition;
    --
    -- Remember IN OUT parameter IN values
    --
    l_object_version_number := p_object_version_number;
    --
    -- Call Before Process User Hook
    --
    begin
      ame_condition_bk2.update_ame_condition_b
        (p_condition_id          => p_condition_id
        ,p_parameter_one         => p_parameter_one
        ,p_parameter_two         => p_parameter_two
        ,p_parameter_three       => p_parameter_three
        ,p_include_upper_limit   => p_include_upper_limit
        ,p_include_lower_limit   => p_include_lower_limit
        ,p_object_version_number => p_object_version_number
        );
    exception
      when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error
          (p_module_name => 'update_ame_condition'
          ,p_hook_type   => 'BP'
          );
    end;
    --
    -- Process Logic
    --
    ame_con_upd.upd(p_effective_date        => sysdate
                   ,p_datetrack_mode        => hr_api.g_update
                   ,p_condition_id          => p_condition_id
                   ,p_object_version_number => p_object_version_number
                   ,p_parameter_one         => p_parameter_one
                   ,p_parameter_two         => p_parameter_two
                   ,p_parameter_three       => p_parameter_three
                   ,p_include_upper_limit   => p_include_upper_limit
                   ,p_include_lower_limit   => p_include_lower_limit
                   ,p_security_group_id     => hr_api.g_number
                   ,p_start_date            => l_start_date
                   ,p_end_date              => l_end_date
                   );
    --
    -- Call After Process User Hook
    --
    begin
      ame_condition_bk2.update_ame_condition_a
        (p_condition_id          => p_condition_id
        ,p_parameter_one         => p_parameter_one
        ,p_parameter_two         => p_parameter_two
        ,p_parameter_three       => p_parameter_three
        ,p_include_upper_limit   => p_include_upper_limit
        ,p_include_lower_limit   => p_include_lower_limit
        ,p_object_version_number => p_object_version_number
        ,p_start_date            => l_start_date
        ,p_end_date              => l_end_date
        );
    exception
      when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error
          (p_module_name => 'update_ame_condition'
          ,p_hook_type   => 'AP'
          );
    end;
    --
    -- When in validation only mode raise the Validate_Enabled exception
    --
    if p_validate then
      raise hr_api.validate_enabled;
    end if;
    --
    -- Set all IN OUT and OUT parameters with out values.
    --
    p_start_date   := l_start_date;
    p_end_date     := l_end_date;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 70);
  exception
    when hr_api.validate_enabled then
      --
      -- As the Validate_Enabled exception has been raised
      -- we must rollback to the savepoint
      --
      rollback to update_ame_condition;
      --
      -- Reset IN OUT parameters and set OUT parameters
      -- (Any key or derived arguments must be set to null
      -- when validation only mode is being used.)
      --
      p_object_version_number  := l_object_version_number;
      p_start_date             := null;
      p_end_date               := null;
      --
      hr_utility.set_location(' Leaving:'||l_proc, 80);
    when others then
      --
      -- A validation or unexpected error has occured
      --
      rollback to update_ame_condition;
      --
      -- Reset IN OUT parameters and set all
      -- OUT parameters, including warnings, to null
      --
      p_object_version_number  := l_object_version_number;
      p_start_date             := null;
      p_end_date               := null;
      --
      hr_utility.set_location(' Leaving:'||l_proc, 90);
      raise;
  end update_ame_condition;
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< DELETE_AME_CONDITION >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ame_condition
  (p_validate              in     boolean  default false
  ,p_condition_id          in     number
  ,p_object_version_number in out nocopy   number
  ,p_start_date               out nocopy   date
  ,p_end_date                 out nocopy   date
  ) is
  --
  -- Declare cursors and local variables
  --
  cursor ame_str_vals is
         select string_value, object_version_number
           from ame_string_values
          where condition_id = p_condition_id
            and sysdate between start_date and
                  nvl(end_date - ame_util.oneSecond,sysdate);
  cursor csr_rules(p_chk_condition_id number) is
         select null
           from ame_rules,
                ame_rule_usages,
                ame_condition_usages
          where ame_rules.rule_id = ame_condition_usages.rule_id
            and ame_rules.rule_id = ame_rule_usages.rule_id
            and ame_condition_usages.condition_id = p_chk_condition_id
            and ((sysdate between ame_rules.start_date and
                   nvl(ame_rules.end_date - ame_util.oneSecond,sysdate))
                 or
                 (sysdate < ame_rules.start_date and
                    ame_rules.start_date < nvl(ame_rules.end_date,
                      ame_rules.start_date + ame_util.oneSecond)))
            and ((sysdate between ame_rule_usages.start_date and
                   nvl(ame_rule_usages.end_date - ame_util.oneSecond,sysdate))
                 or
                 (sysdate < ame_rule_usages.start_date and
                  ame_rule_usages.start_date < nvl(ame_rule_usages.end_date,
                    ame_rule_usages.start_date + ame_util.oneSecond)))
            and ((sysdate between ame_condition_usages.start_date and
                nvl(ame_condition_usages.end_date-ame_util.oneSecond,sysdate))
                or
                (sysdate < ame_condition_usages.start_date and
                   ame_condition_usages.start_date <
                     nvl(ame_condition_usages.end_date,
                       ame_condition_usages.start_date + ame_util.oneSecond)));
  --
  l_proc                      varchar2(72) := g_package||'delete_ame_condition';
  l_object_version_number     number;
  l_start_date                date;
  l_end_date                  date;
  l_isStringCondition         boolean;
  l_key                       varchar2(1);
  l_string_value_tab          ame_util.longestStringList;
  l_object_version_number_tab ame_util.idList;
  --
  begin
    hr_utility.set_location('Entering:'|| l_proc, 10);
    --
    -- Issue a savepoint
    --
    savepoint delete_ame_condition;
    --
    -- Remember IN OUT parameter IN values
    --
    l_object_version_number := p_object_version_number;
    --
    -- Call Before Process User Hook
    --
    begin
      ame_condition_bk3.delete_ame_condition_b
        (p_condition_id             => p_condition_id
        ,p_object_version_number    => p_object_version_number
        );
    exception
      when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error
          (p_module_name => 'delete_ame_condition'
          ,p_hook_type   => 'BP'
          );
    end;
    --
    -- Process Logic
    --
    -- Determine if the condition is being used by any rule. If yes, then
    -- throw an error mentioning the same.
    open csr_rules(p_condition_id);
    fetch csr_rules into l_key;
    if(csr_rules%found) then
      close csr_rules;
      fnd_message.set_name('PER', 'AME_400193_CON_IN USE');
      fnd_message.raise_error;
    else
      close csr_rules;
      -- Determine if the condition is based on string attributes. If yes, call
      -- the deleteAllStringValues api to delete associated string values
      --
      l_isStringCondition := is_string_condition(p_effective_date => sysdate
                                            ,p_condition_id   => p_condition_id
                                            );
      if(l_isStringCondition) then
        open ame_str_vals;
        fetch ame_str_vals bulk collect into l_string_value_tab
                                            ,l_object_version_number_tab;
        close ame_str_vals;
        if(l_string_value_tab.count > 0) then
          for indx in 1..l_string_value_tab.count loop
            delete_ame_string_value
                (p_validate                => p_validate
                ,p_condition_id            => p_condition_id
                ,p_string_value            => l_string_value_tab(indx)
                ,p_object_version_number   => l_object_version_number_tab(indx)
                ,p_start_date              => l_start_date
                ,p_end_date                => l_end_date
                );
          end loop;
        end if;
      end if;
      ame_con_del.del(p_effective_date          => sysdate
                     ,p_datetrack_mode          => hr_api.g_delete
                     ,p_condition_id            => p_condition_id
                     ,p_object_version_number   => p_object_version_number
                     ,p_start_date              => l_start_date
                     ,p_end_date                => l_end_date
                     );
      --
      -- Call After Process User Hook
      --
      begin
        ame_condition_bk3.delete_ame_condition_a
        (p_condition_id            => p_condition_id
        ,p_object_version_number   => p_object_version_number
        ,p_start_date              => l_start_date
        ,p_end_date                => l_end_date
        );
      exception
        when hr_api.cannot_find_prog_unit then
          hr_api.cannot_find_prog_unit_error
            (p_module_name => 'delete_ame_condition'
            ,p_hook_type   => 'AP'
            );
      end;
      --
      -- When in validation only mode raise the Validate_Enabled exception
      --
      if p_validate then
        raise hr_api.validate_enabled;
      end if;
      --
      -- Set all IN OUT and OUT parameters with out values.
      --
      p_start_date  := l_start_date;
      p_end_date    := l_end_date;
      --
    end if;
    hr_utility.set_location(' Leaving:'||l_proc, 70);
  exception
    when hr_api.validate_enabled then
      --
      -- As the Validate_Enabled exception has been raised
      -- we must rollback to the savepoint
      --
      rollback to delete_ame_condition;
      --
      -- Reset IN OUT parameters and set OUT parameters
      -- (Any key or derived arguments must be set to null
      -- when validation only mode is being used.)
      --
      p_object_version_number := l_object_version_number;
      p_start_date            := null;
      p_end_date              := null;
      --
      hr_utility.set_location(' Leaving:'||l_proc, 80);
    when others then
      --
      -- A validation or unexpected error has occured
      --
      rollback to delete_ame_condition;
      --
      -- Reset IN OUT parameters and set all
      -- OUT parameters, including warnings, to null
      --
      p_object_version_number := l_object_version_number;
      p_start_date            := null;
      p_end_date              := null;
      --
      hr_utility.set_location(' Leaving:'||l_proc, 90);
      raise;
  end delete_ame_condition;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< CREATE_AME_STRING_VALUE >------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_ame_string_value
  (p_validate             in     boolean  default false
  ,p_condition_id         in     number
  ,p_string_value         in     varchar2
  ,p_object_version_number   out nocopy   number
  ,p_start_date              out nocopy   date
  ,p_end_date                out nocopy   date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                   varchar2(72) := g_package||'create_ame_string_value';
  l_object_version_number  number;
  l_start_date             date;
  l_end_date               date;
  --
  begin
    hr_utility.set_location('Entering:'|| l_proc, 10);
    --
    -- Issue a savepoint
    --
    savepoint create_ame_string_value;
    --
    -- Remember IN OUT parameter IN values.(None to remember here)
    --
    -- Call Before Process User Hook
    --
    begin
      ame_condition_bk4.create_ame_string_value_b
                         (p_condition_id        => p_condition_id
                         ,p_string_value        => p_string_value
                         );
    exception
      when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error
          (p_module_name => 'create_ame_string_value'
          ,p_hook_type   => 'BP'
          );
    end;
    --
    -- Process Logic.
    --
    ame_stv_ins.ins(p_effective_date                => sysdate
                   ,p_security_group_id             => null
                   ,p_condition_id                  => p_condition_id
                   ,p_string_value                  => p_string_value
                   ,p_object_version_number         => l_object_version_number
                   ,p_start_date                    => l_start_date
                   ,p_end_date                      => l_end_date
                   );
    --
    -- Call After Process User Hook
    --
   begin
      ame_condition_bk4.create_ame_string_value_a
                   (p_condition_id                  => p_condition_id
                   ,p_string_value                  => p_string_value
                   ,p_object_version_number         => l_object_version_number
                   ,p_start_date                    => l_start_date
                   ,p_end_date                      => l_end_date
                   );
    exception
      when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error
          (p_module_name => 'create_ame_string_value'
          ,p_hook_type   => 'AP'
          );
    end;
    --
    -- When in validation only mode raise the Validate_Enabled exception
    --
    if p_validate then
      raise hr_api.validate_enabled;
    end if;
    --
    -- Set all IN OUT and OUT parameters with out values.
    --
    p_object_version_number := l_object_version_number;
    p_start_date            := l_start_date;
    p_end_date              := l_end_date;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 70);
  exception
    when hr_api.validate_enabled then
      --
      -- As the Validate_Enabled exception has been raised
      -- we must rollback to the savepoint
      --
      rollback to create_ame_string_value;
      --
      -- Reset IN OUT parameters and set OUT parameters
      -- (Any key or derived arguments must be set to null
      -- when validation only mode is being used.)
      --
      p_object_version_number  := null;
      p_start_date             := null;
      p_end_date               := null;
      --
      hr_utility.set_location(' Leaving:'||l_proc, 80);
    when others then
      --
      -- A validation or unexpected error has occured
      --
      rollback to create_ame_string_value;
      --
      -- Reset IN OUT parameters and set all
      -- OUT parameters, including warnings, to null
      --
      p_object_version_number  := null;
      p_start_date             := null;
      p_end_date               := null;
      --
      hr_utility.set_location(' Leaving:'||l_proc, 90);
      raise;
  end create_ame_string_value;
--
--
-- ----------------------------------------------------------------------------
-- |----------------------< DELETE_AME_STRING_VALUE >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ame_string_value
  (p_validate              in     boolean  default false
  ,p_condition_id          in     number
  ,p_string_value          in     varchar2
  ,p_object_version_number in out nocopy   number
  ,p_start_date               out nocopy   date
  ,p_end_date                 out nocopy   date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                   varchar2(72) := g_package||'delete_ame_string_value';
  l_object_version_number  number;
  l_start_date             date;
  l_end_date               date;
  --
  begin
    hr_utility.set_location('Entering:'|| l_proc, 10);
    --
    -- Issue a savepoint
    --
    savepoint delete_ame_string_value;
    --
    -- Remember IN OUT parameter IN values
    --
    l_object_version_number := p_object_version_number;
    --
    -- Call Before Process User Hook
    --
    begin
      ame_condition_bk5.delete_ame_string_value_b
        (p_condition_id             => p_condition_id
        ,p_string_value             => p_string_value
        ,p_object_version_number    => p_object_version_number
        );
    exception
      when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error
          (p_module_name => 'delete_ame_string_value'
          ,p_hook_type   => 'BP'
          );
    end;
    --
    -- Process Logic
    --
    ame_stv_del.del(p_effective_date          => sysdate
                   ,p_datetrack_mode          => hr_api.g_delete
                   ,p_condition_id            => p_condition_id
                   ,p_string_value            => p_string_value
                   ,p_object_version_number   => p_object_version_number
                   ,p_start_date              => l_start_date
                   ,p_end_date                => l_end_date
                   );
    --
    -- Call After Process User Hook
    --
    begin
      ame_condition_bk5.delete_ame_string_value_a
        (p_condition_id            => p_condition_id
        ,p_string_value            => p_string_value
        ,p_object_version_number   => p_object_version_number
        ,p_start_date              => l_start_date
        ,p_end_date                => l_end_date
        );
    exception
      when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error
          (p_module_name => 'delete_ame_string_value'
          ,p_hook_type   => 'AP'
          );
    end;
    --
    -- When in validation only mode raise the Validate_Enabled exception
    --
    if p_validate then
      raise hr_api.validate_enabled;
    end if;
    --
    -- Set all IN OUT and OUT parameters with out values.
    --
    p_start_date   := l_start_date;
    p_end_date     := l_end_date;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 70);
  exception
    when hr_api.validate_enabled then
      --
      -- As the Validate_Enabled exception has been raised
      -- we must rollback to the savepoint
      --
      rollback to delete_ame_string_value;
      --
      -- Reset IN OUT parameters and set OUT parameters
      -- (Any key or derived arguments must be set to null
      -- when validation only mode is being used.)
      --
      p_object_version_number := l_object_version_number;
      p_start_date            := null;
      p_end_date              := null;
      --
      hr_utility.set_location(' Leaving:'||l_proc, 80);
    when others then
      --
      -- A validation or unexpected error has occured
      --
      rollback to delete_ame_string_value;
      --
      -- Reset IN OUT parameters and set all
      -- OUT parameters, including warnings, to null
      --
      p_object_version_number := l_object_version_number;
      p_start_date            := null;
      p_end_date              := null;
      --
      hr_utility.set_location(' Leaving:'||l_proc, 90);
      raise;
  end delete_ame_string_value;
end AME_CONDITION_API;

/
