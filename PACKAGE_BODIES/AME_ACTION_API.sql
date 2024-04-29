--------------------------------------------------------
--  DDL for Package Body AME_ACTION_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_ACTION_API" as
/* $Header: amatyapi.pkb 120.0 2005/09/02 03:52:24 mbocutt noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'ame_action_api.';
--
function get_action_type_order_number(p_ame_application_id in number,
                                      p_action_type_id in number) return number as
  l_proc         varchar2(72) := g_package||'get_action_type_order_number';
  l_order_number number;
  begin
    hr_utility.set_location('Entering:'|| l_proc, 10);
    select order_number
      into l_order_number
      from ame_action_type_config
      where
        action_type_id = p_action_type_id and
        application_id = p_ame_application_id and
        sysdate between start_date and
          nvl(end_date - ame_util.oneSecond, sysdate);
    return(l_order_number);
    exception
      when others then
        hr_utility.set_location(' Leaving:'||l_proc, 60);
        raise;
        return(null);
  end get_action_type_order_number;
--
function get_allowed_rule_type(p_action_type_id in number) return number as
  l_proc       varchar2(72) := g_package||'get_allowed_rule_type';
  l_rule_type  number;
  l_temp_count number;
  begin
    hr_utility.set_location('Entering:'|| l_proc, 10);
    select count(*)
      into l_temp_count
      from ame_action_type_usages
      where
        action_type_id = p_action_type_id and
        sysdate between start_date and
          nvl(end_date - ame_util.oneSecond, sysdate);
    if(l_temp_count > 1) then
      /* authority and exception rule types are mapped to the action type */
      /* return chain of authority */
      return(ame_util.authorityRuleType);
    else
      select rule_type
        into l_rule_type
        from ame_action_type_usages
        where
          action_type_id = p_action_type_id and
          sysdate between start_date and
            nvl(end_date - ame_util.oneSecond, sysdate);
      return(l_rule_type);
    end if;
    exception
      when others then
        hr_utility.set_location(' Leaving:'||l_proc, 60);
        raise;
        return(null);
  end get_allowed_rule_type;
--
function get_max_order_number(p_ame_application_id in number,
                              p_action_type_id in number) return number as
  l_proc         varchar2(72) := g_package||'get_max_order_number';
  l_order_number number;
  l_rule_type    number;
  begin
    hr_utility.set_location('Entering:'|| l_proc, 10);
    l_rule_type := get_allowed_rule_type(p_action_type_id => p_action_type_id);
    select max(order_number)
      into l_order_number
      from ame_action_type_config,
           ame_action_type_usages,
           ame_action_types
      where
        ame_action_types.action_type_id = ame_action_type_usages.action_type_id and
        ame_action_types.action_type_id = ame_action_type_config.action_type_id and
        ame_action_type_config.application_id = p_ame_application_id and
        ame_action_type_usages.rule_type = l_rule_type and
        sysdate between ame_action_type_config.start_date and
          nvl(ame_action_type_config.end_date - ame_util.oneSecond, sysdate) and
        sysdate between ame_action_types.start_date and
          nvl(ame_action_types.end_date - ame_util.oneSecond, sysdate) and
        sysdate between ame_action_type_usages.start_date and
          nvl(ame_action_type_usages.end_date - ame_util.oneSecond, sysdate);
    return(l_order_number);
    exception
      when others then
        hr_utility.set_location(' Leaving:'||l_proc, 50);
        raise;
        return(null);
  end get_max_order_number;
--
function order_number_unique(p_ame_application_id in number,
                             p_order_number in number,
                             p_action_type_id in number) return boolean as
  l_proc       varchar2(72) := g_package||'order_number_unique';
  l_rule_type  number;
  l_temp_count number;
  begin
    hr_utility.set_location('Entering:'|| l_proc, 10);
    l_rule_type := get_allowed_rule_type(p_action_type_id => p_action_type_id);
    select count(*)
      into l_temp_count
      from ame_action_type_config,
           ame_action_type_usages,
           ame_action_types
      where
        ame_action_types.action_type_id = ame_action_type_usages.action_type_id and
        ame_action_types.action_type_id = ame_action_type_config.action_type_id and
        ame_action_type_config.application_id = p_ame_application_id and
        ame_action_type_config.order_number = p_order_number and
        ame_action_type_usages.rule_type = l_rule_type and
        sysdate between ame_action_type_config.start_date and
          nvl(ame_action_type_config.end_date - ame_util.oneSecond, sysdate) and
        sysdate between ame_action_types.start_date and
          nvl(ame_action_types.end_date - ame_util.oneSecond, sysdate) and
        sysdate between ame_action_type_usages.start_date and
          nvl(ame_action_type_usages.end_date - ame_util.oneSecond, sysdate);
    if(l_temp_count > 1) then
      return(false);
    else
      return(true);
    end if;
    exception
      when others then
        hr_utility.set_location(' Leaving:'||l_proc, 60);
        raise;
        return(false);
  end order_number_unique;
--
procedure decrement_action_type_ord_nums(p_ame_application_id in number,
                                         p_action_type_id in number,
                                         p_order_number in number) as
  cursor c_sel1(p_ame_application_id in number,
                p_order_number in number,
                p_rule_type in number) is
    select ame_action_type_config.action_type_id,
           ame_action_type_config.order_number,
           ame_action_type_config.object_version_number,
           ame_action_types.object_version_number
      from ame_action_type_config,
           ame_action_type_usages,
           ame_action_types
      where
        ame_action_types.action_type_id = ame_action_type_usages.action_type_id and
        ame_action_types.action_type_id = ame_action_type_config.action_type_id and
        ame_action_type_config.application_id = p_ame_application_id and
        ame_action_type_config.order_number > p_order_number and
        ame_action_type_usages.rule_type = p_rule_type and
        sysdate between ame_action_type_config.start_date and
          nvl(ame_action_type_config.end_date - ame_util.oneSecond, sysdate) and
        sysdate between ame_action_types.start_date and
          nvl(ame_action_types.end_date - ame_util.oneSecond, sysdate) and
        sysdate between ame_action_type_usages.start_date and
          nvl(ame_action_type_usages.end_date - ame_util.oneSecond, sysdate)
        order by order_number;
  l_proc  varchar2(72) := g_package||'decrement_action_type_ord_nums';
  l_action_type_ids ame_util.idList;
  l_order_numbers ame_util.idList;
  l_acf_object_version_numbers ame_util.idList;
  l_aty_object_version_numbers ame_util.idList;
  l_rule_type number;
  l_effective_date date;
  l_acf_object_version_number number;
  l_aty_object_version_number number;
  l_acf_start_date date;
  l_aty_start_date date;
  l_acf_end_date date;
  l_aty_end_date date;
  begin
    hr_utility.set_location('Entering:'|| l_proc, 10);
    l_effective_date := sysdate;
    l_rule_type := get_allowed_rule_type(p_action_type_id => p_action_type_id);
    open c_sel1(p_ame_application_id => p_ame_application_id,
                p_order_number => p_order_number,
                p_rule_type => l_rule_type);
    fetch c_sel1 bulk collect
      into l_action_type_ids,
           l_order_numbers,
           l_acf_object_version_numbers,
           l_aty_object_version_numbers;
    close c_sel1;
    for i in 1 .. l_action_type_ids.count loop
      -- Update action type config details
      ame_acf_upd.upd(p_effective_date => l_effective_date
                     ,p_datetrack_mode => 'UPDATE'
                     ,p_application_id => p_ame_application_id
                     ,p_action_type_id   => l_action_type_ids(i)
                     ,p_order_number => (l_order_numbers(i) - 1)
                     ,p_object_version_number  => l_acf_object_version_numbers(i)
                     ,p_start_date     => l_acf_start_date
                     ,p_end_date       => l_acf_end_date
                     );
    end loop;
    hr_utility.set_location(' Leaving:'||l_proc, 50);
    exception
     when others then
        hr_utility.set_location(' Leaving:'||l_proc, 60);
        rollback;
        raise;
  end decrement_action_type_ord_nums;
--
procedure increment_action_type_ord_nums(p_ame_application_id in number,
                                         p_action_type_id in number,
                                         p_order_number in number) as
  cursor c_sel1(p_ame_application_id in number,
                p_action_type_id in number,
                p_order_number in number,
                p_rule_type in number) is
    select ame_action_type_config.action_type_id,
           ame_action_type_config.order_number,
           ame_action_type_config.object_version_number,
           ame_action_types.object_version_number
      from ame_action_type_config,
           ame_action_type_usages,
           ame_action_types
      where
        ame_action_type_config.action_type_id = ame_action_types.action_type_id and
        ame_action_type_usages.action_type_id = ame_action_types.action_type_id and
        ame_action_type_config.application_id = p_ame_application_id and
        ame_action_type_config.action_type_id <> p_action_type_id and
        ame_action_type_config.order_number >= p_order_number and
        ame_action_type_usages.rule_type = p_rule_type and
        sysdate between ame_action_type_config.start_date and
          nvl(ame_action_type_config.end_date - ame_util.oneSecond, sysdate) and
        sysdate between ame_action_types.start_date and
          nvl(ame_action_types.end_date - ame_util.oneSecond, sysdate) and
        sysdate between ame_action_type_usages.start_date and
          nvl(ame_action_type_usages.end_date - ame_util.oneSecond, sysdate)
        order by order_number;
  l_proc varchar2(72) := g_package||'increment_action_type_ord_nums';
  l_effective_date date;
  l_action_type_ids ame_util.idList;
  l_acf_object_version_numbers ame_util.idList;
  l_aty_object_version_numbers ame_util.idList;
  l_order_numbers ame_util.idList;
  l_rule_type integer;
  l_acf_object_version_number number;
  l_aty_object_version_number number;
  l_acf_start_date date;
  l_aty_start_date date;
  l_acf_end_date date;
  l_aty_end_date date;
  begin
    hr_utility.set_location('Entering:'|| l_proc, 10);
    l_effective_date := sysdate;
    l_rule_type := get_allowed_rule_type(p_action_type_id => p_action_type_id);
    open c_sel1(p_ame_application_id => p_ame_application_id,
                p_action_type_id => p_action_type_id,
                p_order_number => p_order_number,
                p_rule_type => l_rule_type);
      fetch c_sel1 bulk collect
        into l_action_type_ids,
             l_order_numbers,
             l_acf_object_version_numbers,
             l_aty_object_version_numbers;
    close c_sel1;
    for i in 1 .. l_action_type_ids.count loop
      -- Update action type config details
      ame_acf_upd.upd(p_effective_date => l_effective_date
                     ,p_datetrack_mode => 'UPDATE'
                     ,p_application_id => p_ame_application_id
                     ,p_action_type_id   => l_action_type_ids(i)
                     ,p_order_number => (l_order_numbers(i) + 1)
                     ,p_object_version_number  => l_acf_object_version_numbers(i)
                     ,p_start_date     => l_acf_start_date
                     ,p_end_date       => l_acf_end_date
                     );
    end loop;
    hr_utility.set_location(' Leaving:'||l_proc, 50);
    exception
     when others then
        hr_utility.set_location(' Leaving:'||l_proc, 60);
        rollback;
        raise;
  end increment_action_type_ord_nums;
--
-- ----------------------------------------------------------------------------
-- |-------------------< create_ame_action_type >------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_ame_action_type
  (p_validate                  in     boolean  default false
  ,p_language_code             in     varchar2 default hr_api.userenv_lang
  ,p_name                      in     varchar2
  ,p_procedure_name            in     varchar2
  ,p_dynamic_description       in     varchar2
  ,p_description               in     varchar2
  ,p_description_query         in     varchar2 default null
  ,p_rule_type                 in     number default null
  ,p_approver_type_id          in     number default null
  ,p_action_type_id            out nocopy   number
  ,p_aty_object_version_number out nocopy   number
  ,p_aty_start_date            out nocopy   date
  ,p_aty_end_date              out nocopy   date
  ,p_apu_object_version_number out nocopy   number
  ,p_apu_start_date            out nocopy   date
  ,p_apu_end_date              out nocopy   date
  ) is
  cursor application_cur(p_effective_date in date) is
    select application_id
      from ame_calling_apps
        where p_effective_date between start_date
          and nvl(end_date - ame_util.oneSecond, p_effective_date);
  -- local variables
  l_proc                         varchar2(72) := g_package||'create_ame_action_type';
  l_action_type_id               number;
  l_effective_date               date;
  l_aty_object_version_number    number;
  l_aty_start_date               date;
  l_aty_end_date                 date;
  l_axu_object_version_number    number;
  l_axu_start_date               date;
  l_axu_end_date                 date;
  l_acf_object_version_number    number;
  l_acf_start_date               date;
  l_acf_end_date                 date;
  l_apu_object_version_number    number;
  l_apu_start_date               date;
  l_apu_end_date                 date;
  l_language_code                fnd_languages.language_code%TYPE;
  l_application_ids              ame_util.idList;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  -- Validate language code
  l_language_code := p_language_code;
  hr_api.validate_language_code(p_language_code => l_language_code);
  -- Set the effective date to the sysdate
  l_effective_date := sysdate;
  -- Issue a savepoint.
  --
  savepoint create_ame_action_type;
  --
  -- Call Before Process User Hook
  --
  begin
    ame_action_bk1.create_ame_action_type_b
      (p_language_code           => p_language_code
      ,p_name                    => p_name
      ,p_procedure_name          => p_procedure_name
      ,p_description             => p_description
      ,p_dynamic_description     => p_dynamic_description
      ,p_description_query       => p_description_query
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_ame_action_type'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- insert the row in ame_action_types.
  ame_aty_ins.ins(p_effective_date        => l_effective_date,
                  p_name                  => p_name,
                  p_procedure_name        => p_procedure_name,
                  p_description           => p_description,
                  p_dynamic_description   => p_dynamic_description,
                  p_description_query     => p_description_query,
                  p_action_type_id        => l_action_type_id,
                  p_object_version_number => l_aty_object_version_number,
                  p_start_date            => l_aty_start_date,
                  p_end_date              => l_aty_end_date
                 );
  -- Insert data into TL Table
  ame_ayl_ins.ins_tl(p_language_code => l_language_code,
                     p_action_type_id => l_action_type_id,
                     p_user_action_type_name => p_name,
                     p_description => p_description
                    );
  -- Call after process user hook
  begin
    ame_action_bk1.create_ame_action_type_a
      (p_language_code           => p_language_code
      ,p_name                    => p_name
      ,p_procedure_name          => p_procedure_name
      ,p_description             => p_description
      ,p_dynamic_description     => p_dynamic_description
      ,p_description_query       => p_description_query
      ,p_action_type_id          => l_action_type_id
      ,p_object_version_number   => l_aty_object_version_number
      ,p_start_date              => l_aty_start_date
      ,p_end_date                => l_aty_end_date
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_ame_action_type'
        ,p_hook_type   => 'AP'
        );
  end;
  -- insert the row in ame_action_type_usages
  -- Call DBMS_UTILITY.FORMAT_CALL_STACK to check if the call has been
  -- made from the 'AME_ACTION_SWI' package.
  if (instrb(DBMS_UTILITY.FORMAT_CALL_STACK,'AME_ACTION_SWI') = 0) then
    create_ame_appr_type_usage(p_validate => p_validate,
                               p_action_type_id => l_action_type_id,
                               p_approver_type_id => p_approver_type_id,
                               p_object_version_number => l_apu_object_version_number,
                               p_start_date => l_apu_start_date,
                               p_end_date => l_apu_end_date);
    create_ame_action_type_usage(p_validate => p_validate,
                                 p_action_type_id => l_action_type_id,
                                 p_rule_type => p_rule_type,
                                 p_object_version_number => l_axu_object_version_number,
                                 p_start_date => l_axu_start_date,
                                 p_end_date => l_axu_end_date);
/*
    create_ame_action_type_config(p_validate => p_validate,
                                    p_action_type_id => l_action_type_id,
                                    p_application_id => p_application_id,
                                    p_rule_type => p_rule_type,
                                    p_object_version_number => l_acf_object_version_number,
                                    p_start_date => l_acf_start_date,
                                    p_end_date => l_acf_end_date);
*/
  end if;
  --
  p_action_type_id             := l_action_type_id;
  p_aty_object_version_number  := l_aty_object_version_number;
  p_aty_start_date             := l_aty_start_date;
  p_aty_end_date               := l_aty_end_date;
  p_apu_object_version_number  := l_apu_object_version_number;
  p_apu_start_date             := l_apu_start_date;
  p_apu_end_date               := l_apu_end_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 50);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_ame_action_type;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_action_type_id             := null;
    p_aty_object_version_number  := null;
    p_aty_start_date             := null;
    p_aty_end_date               := null;
    p_apu_object_version_number  := null;
    p_apu_start_date             := null;
    p_apu_end_date               := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 60);
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    p_action_type_id             := null;
    p_aty_object_version_number  := null;
    p_aty_start_date             := null;
    p_aty_end_date               := null;
    p_apu_object_version_number  := null;
    p_apu_start_date             := null;
    p_apu_end_date               := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 70);
    ROLLBACK TO create_ame_action_type;
    raise;
    --
end create_ame_action_type;
-- ----------------------------------------------------------------------------
-- |-------------------< create_ame_action_type_usage >------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_ame_action_type_usage
  (p_validate                  in boolean  default false
  ,p_action_type_id            in number
  ,p_rule_type                 in number
  ,p_object_version_number     out nocopy   number
  ,p_start_date                out nocopy   date
  ,p_end_date                  out nocopy   date
  ) is
  -- local variables
  l_proc                      varchar2(72) := g_package||'create_ame_action_type_usage';
  l_effective_date            date;
  l_object_version_number     number;
  l_start_date                date;
  l_end_date                  date;
  l_approver_count            number;
  l_rule_type                 number;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Set the effective date to the sysdate
  l_effective_date := sysdate;
  -- Issue a savepoint.
  --
  savepoint create_ame_action_type_usage;
  --
/*  if(p_rule_type = ame_util.exceptionRuleType) then
    -- chain of authority so insert two rows,
      -- one for list-creation and one for list-exception
-- isthis loop required?
    for i in 1 .. 2 loop
      -- Call Before Process User Hook
      begin
        ame_action_bk13.create_ame_action_type_usage_b
          (p_action_type_id => p_action_type_id
          ,p_rule_type => i
          );
        exception
          when hr_api.cannot_find_prog_unit then
            hr_api.cannot_find_prog_unit_error
              (p_module_name => 'create_ame_action_type_usage'
              ,p_hook_type   => 'BP'
              );
      end;
      ame_axu_ins.ins(p_action_type_id        => p_action_type_id,
                      p_effective_date        => l_effective_date ,
                      p_rule_type             => i,
                      p_object_version_number => l_object_version_number,
                      p_start_date            => l_start_date,
                      p_end_date              => l_end_date
                      );
      -- Call After Process User Hook
      begin
        ame_action_bk13.create_ame_action_type_usage_a
          (p_action_type_id => p_action_type_id
          ,p_rule_type => i
          ,p_object_version_number   => l_object_version_number
          ,p_start_date => l_start_date
          ,p_end_date   => l_end_date
          );
        exception
          when hr_api.cannot_find_prog_unit then
            hr_api.cannot_find_prog_unit_error
              (p_module_name => 'create_ame_action_type_usage'
              ,p_hook_type   => 'AP'
              );
      end;
    end loop;
  else*/
-- no b4 user hook
    if(p_rule_type = ame_util.exceptionRuleType) then
      l_rule_type := p_rule_type-1;
    else
      l_rule_type := p_rule_type;
    end if;

    -- Call Before Process User Hook
    begin
      ame_action_bk13.create_ame_action_type_usage_b
        (p_action_type_id => p_action_type_id
        ,p_rule_type => l_rule_type
        );
      exception
        when hr_api.cannot_find_prog_unit then
          hr_api.cannot_find_prog_unit_error
            (p_module_name => 'create_ame_action_type_usage'
            ,p_hook_type   => 'BP'
            );
    end;



    ame_axu_ins.ins(p_action_type_id        => p_action_type_id,
                    p_effective_date        => l_effective_date,
                    p_rule_type             => l_rule_type,
                    p_object_version_number => l_object_version_number,
                    p_start_date            => l_start_date,
                    p_end_date              => l_end_date
                        );
    -- Call After Process User Hook
    begin
      ame_action_bk13.create_ame_action_type_usage_a
        (p_action_type_id => p_action_type_id
        ,p_rule_type => l_rule_type
        ,p_object_version_number   => l_object_version_number
        ,p_start_date => l_start_date
        ,p_end_date   => l_end_date
        );
      exception
        when hr_api.cannot_find_prog_unit then
          hr_api.cannot_find_prog_unit_error
            (p_module_name => 'create_ame_action_type_usage'
            ,p_hook_type   => 'AP'
            );
    end;
--  end if;
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  p_object_version_number  := l_object_version_number;
  p_start_date             := l_start_date;
  p_end_date               := l_end_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 50);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_ame_action_type_usage;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := null;
    p_start_date             := null;
    p_end_date               := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 60);
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    p_object_version_number  := null;
    p_start_date             := null;
    p_end_date               := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 70);
    ROLLBACK TO create_ame_action_type_usage;
    raise;
    --
end create_ame_action_type_usage;
-- ----------------------------------------------------------------------------
-- |-------------------< create_ame_appr_type_usage >------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_ame_appr_type_usage
  (p_validate                  in boolean  default false
  ,p_action_type_id            in number
  ,p_approver_type_id          in number
  ,p_object_version_number     out nocopy   number
  ,p_start_date                out nocopy   date
  ,p_end_date                  out nocopy   date
  ) is
  -- local variables
  l_proc                      varchar2(72) := g_package||'create_ame_appr_type_usage';
  l_effective_date            date;
  l_object_version_number     number;
  l_start_date                date;
  l_end_date                  date;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Set the effective date to the sysdate
  l_effective_date := sysdate;
  -- Issue a savepoint.
  --
  savepoint create_ame_appr_type_usage;
  --
  -- Call Before Process User Hook
  begin
    ame_action_bk2.create_ame_appr_type_usage_b
      (p_approver_type_id => p_approver_type_id
      ,p_action_type_id   => p_action_type_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_ame_appr_type_usage'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  -- insert the row in ame_approver_type_usages
  ame_apu_ins.ins(p_approver_type_id      => p_approver_type_id
                 ,p_action_type_id        => p_action_type_id
                 ,p_effective_date        => l_effective_date
                 ,p_object_version_number => l_object_version_number
                 ,p_start_date            => l_start_date
                 ,p_end_date              => l_end_date
                 );
  -- Call after process user hook
  begin
    ame_action_bk2.create_ame_appr_type_usage_a
      (p_approver_type_id => p_approver_type_id
      ,p_action_type_id   => p_action_type_id
      ,p_object_version_number => l_object_version_number
      ,p_start_date => l_start_date
      ,p_end_date => l_end_date
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_ame_appr_type_usage'
        ,p_hook_type   => 'AP'
        );
  end;
  -- When in validation only mode raise the Validate_Enabled exception
  hr_utility.set_location(l_proc, 9);
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  p_object_version_number  := l_object_version_number;
  p_start_date             := l_start_date;
  p_end_date               := l_end_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 50);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_ame_appr_type_usage;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := null;
    p_start_date             := null;
    p_end_date               := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 60);
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    p_object_version_number  := null;
    p_start_date             := null;
    p_end_date               := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 70);
    ROLLBACK TO create_ame_appr_type_usage;
    raise;
    --
end create_ame_appr_type_usage;
-- ----------------------------------------------------------------------------
-- |-------------------< create_ame_action_type_conf >------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_ame_action_type_conf
  (p_validate                  in boolean  default false
  ,p_action_type_id            in number
  ,p_application_id            in number
  ,p_voting_regime             in varchar2 default null
  ,p_chain_ordering_mode       in varchar2 default null
  ,p_order_number              in NUMBER   DEFAULT null
  ,p_object_version_number     out nocopy   number
  ,p_start_date                out nocopy   date
  ,p_end_date                  out nocopy   date
  ) is
  -- local variables
  l_proc                      varchar2(72) := g_package||'create_ame_action_type_config';
  l_effective_date            date;
  l_object_version_number     number;
  l_start_date                date;
  l_end_date                  date;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Set the effective date to the sysdate
  l_effective_date := sysdate;
  -- Issue a savepoint.
  --
  savepoint create_ame_action_type_config;
  -- Call DBMS_UTILITY.FORMAT_CALL_STACK to check if the call has been
  -- made from the 'AME_ACTION_SWI' package.
   if (instrb(DBMS_UTILITY.FORMAT_CALL_STACK,'AME_ACTION_SWI') <> 0) then
    -- insert the row in ame_action_type_config with default voting regime
    -- and default chain ordering mode.
/*    l_voting_regime := ame_util.serializedVoting;
    l_chain_ordering_mode := ame_util.serialChainsMode;
*/
    -- Call Before Process User Hook
    begin
      ame_action_bk12.create_ame_action_type_conf_b
        (p_action_type_id => p_action_type_id
        ,p_ame_application_id => p_application_id
        ,p_voting_regime => p_voting_regime
        ,p_chain_ordering_mode => p_chain_ordering_mode
        ,p_order_number => p_order_number
      );
      exception
        when hr_api.cannot_find_prog_unit then
          hr_api.cannot_find_prog_unit_error
            (p_module_name => 'create_ame_action_type_conf'
            ,p_hook_type   => 'BP'
            );
    end;
    ame_acf_ins.ins(p_effective_date => l_effective_date
                   ,p_order_number   => p_order_number
                   ,p_voting_regime  => p_voting_regime
                   ,p_chain_ordering_mode => p_chain_ordering_mode
                   ,p_application_id => p_application_id
                   ,p_action_type_id => p_action_type_id
                   ,p_object_version_number => l_object_version_number
                   ,p_start_date => l_start_date
                   ,p_end_date => l_end_date);
    -- Call After Process User Hook
    begin
      ame_action_bk12.create_ame_action_type_conf_a
        (p_action_type_id => p_action_type_id
        ,p_ame_application_id => p_application_id
        ,p_voting_regime => p_voting_regime
        ,p_chain_ordering_mode => p_chain_ordering_mode
        ,p_order_number => p_order_number
        ,p_object_version_number => l_object_version_number
        ,p_start_date => l_start_date
        ,p_end_date => l_end_date
        );
      exception
        when hr_api.cannot_find_prog_unit then
          hr_api.cannot_find_prog_unit_error
            (p_module_name => 'create_ame_action_type_conf'
            ,p_hook_type   => 'AP'
            );
    end;
  else
      -- Call Before Process User Hook
    begin
      ame_action_bk12.create_ame_action_type_conf_b
        (p_action_type_id => p_action_type_id
        ,p_ame_application_id => p_application_id
        ,p_voting_regime => p_voting_regime
        ,p_chain_ordering_mode => p_chain_ordering_mode
        ,p_order_number => p_order_number
        );
      exception
        when hr_api.cannot_find_prog_unit then
          hr_api.cannot_find_prog_unit_error
            (p_module_name => 'create_ame_action_type_conf'
            ,p_hook_type   => 'BP'
            );
    end;
    ame_acf_ins.ins(p_effective_date => l_effective_date
                   ,p_order_number   => p_order_number
                   ,p_voting_regime  => p_voting_regime
                   ,p_chain_ordering_mode => p_chain_ordering_mode
                   ,p_application_id => p_application_id
                   ,p_action_type_id => p_action_type_id
                   ,p_object_version_number => l_object_version_number
                   ,p_start_date => l_start_date
                   ,p_end_date => l_end_date);
      l_object_version_number := l_object_version_number;
      l_start_date := l_start_date;
      l_end_date := l_end_date;
    -- Call After Process User Hook
    begin
      ame_action_bk12.create_ame_action_type_conf_a
        (p_action_type_id => p_action_type_id
        ,p_ame_application_id => p_application_id
        ,p_voting_regime => p_voting_regime
        ,p_chain_ordering_mode => p_chain_ordering_mode
        ,p_order_number => p_order_number
        ,p_object_version_number => l_object_version_number
        ,p_start_date => l_start_date
        ,p_end_date => l_end_date
        );
      exception
        when hr_api.cannot_find_prog_unit then
          hr_api.cannot_find_prog_unit_error
            (p_module_name => 'create_ame_action_type_conf'
            ,p_hook_type   => 'AP'
            );
    end;
  end if;
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  p_object_version_number  := l_object_version_number;
  p_start_date             := l_start_date;
  p_end_date               := l_end_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 50);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_ame_action_type_config;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := null;
    p_start_date             := null;
    p_end_date               := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 60);
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    p_object_version_number  := null;
    p_start_date             := null;
    p_end_date               := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 70);
    ROLLBACK TO create_ame_action_type_config;
    raise;
    --
end create_ame_action_type_conf;
--
-- ----------------------------------------------------------------------------
-- |-------------------< create_ame_req_attribute >------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_ame_req_attribute
  (p_validate                  in boolean  default false
  ,p_action_type_id            in number
  ,p_attribute_id              in number
  ,p_object_version_number     out nocopy   number
  ,p_start_date                out nocopy   date
  ,p_end_date                  out nocopy   date
  ) is
  --cursors
  cursor C_Sel1 is
    select axu.application_id
      from ame_action_type_config axu
      where axu.action_type_id = p_action_type_id
        and sysdate between axu.start_date
             and nvl(axu.end_date - (1/86400), sysdate)
        and not exists(select null
                         from ame_attribute_usages atu
                         where atu.attribute_id = p_attribute_id
                           and atu.application_id = axu.application_id
                           and sysdate between atu.start_date and
                                   nvl(atu.end_date - (1/86400), sysdate)
                       );

  -- local variables
  l_proc                   varchar2(72) := g_package||'create_ame_req_attribute';
  l_effective_date         date;
  l_object_version_number  number;
  l_start_date             date;
  l_end_date               date;
  l_req_object_version_number number;
  l_req_start_date            date;
  l_req_end_date              date;
  l_attribute_type            ame_attributes.attribute_type%TYPE;
  l_query_string              ame_attribute_usages.query_string%TYPE;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Set the effective date to the sysdate
  l_effective_date := sysdate;
  -- Issue a savepoint.
  --
  savepoint create_ame_req_attribute;
  -- Call Before Process User Hook
  begin
    ame_action_bk3.create_ame_req_attribute_b
      (p_attribute_id    => p_attribute_id
      ,p_action_type_id  => p_action_type_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_ame_req_attribute'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  ame_man_ins.ins(p_action_type_id        => p_action_type_id
                 ,p_attribute_id          => p_attribute_id
                 ,p_effective_date        => l_effective_date
                 ,p_object_version_number => l_object_version_number
                 ,p_start_date            => l_start_date
                 ,p_end_date              => l_end_date);
  --now create usage for this required attribute for all
  --transaction types having config for this action type
  select attribute_type
    into l_attribute_type
    from ame_attributes
    where attribute_id = p_attribute_id
      and sysdate between start_date and
            nvl(end_date - (1/86400), sysdate);
  l_query_string := null;
  if(l_attribute_type = 'currency') then
    l_query_string := '100,USD,Corporate';
  elsif (l_attribute_type = 'boolean') then
    l_query_string := 'true';
  end if;
  for rec in C_Sel1 loop
    ame_attribute_api.create_ame_attribute_usage
                      (
                        p_attribute_id     => p_attribute_id
                       ,p_application_id   => rec.application_id
                       ,p_is_static        => ame_util.booleanTrue
                       ,p_query_string     => l_query_string
                       ,p_object_version_number  => l_req_object_version_number
                       ,p_start_date             => l_req_start_date
                       ,p_end_date               => l_req_end_date
                      );

  end loop;
  -- Call after process user hook
  begin
    ame_action_bk3.create_ame_req_attribute_a
      (p_attribute_id    => p_attribute_id
      ,p_action_type_id  => p_action_type_id
      ,p_object_version_number => l_object_version_number
      ,p_start_date => l_start_date
      ,p_end_date => l_end_date
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_ame_req_attribute'
        ,p_hook_type   => 'AP'
        );
  end;
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  p_object_version_number  := l_object_version_number;
  p_start_date             := l_start_date;
  p_end_date               := l_end_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 50);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_ame_req_attribute;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := null;
    p_start_date             := null;
    p_end_date               := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 60);
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    p_object_version_number  := null;
    p_start_date             := null;
    p_end_date               := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 70);
    ROLLBACK TO create_ame_req_attribute;
    raise;
    --
end create_ame_req_attribute;
--
-- ----------------------------------------------------------------------------
-- |-------------------< create_ame_action >------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_ame_action
  (p_validate                  in     boolean  default false
  ,p_language_code             in     varchar2 default hr_api.userenv_lang
  ,p_action_type_id            in     number
  ,p_parameter                 in     varchar2
  ,p_description               in     varchar2
  ,p_parameter_two             in     varchar2 default null
  ,p_action_id                 out nocopy   number
  ,p_object_version_number     out nocopy   number
  ,p_start_date                out nocopy   date
  ,p_end_date                  out nocopy   date
  ) is
  --cursors
  cursor C_Sel1 is
    select name
      from ame_action_types
      where action_type_id = p_action_type_id
        and sysdate between start_date and
               nvl(end_date - (1/86400), sysdate);
  cursor C_Sel2 is
    select meaning || ': ' || display_name
      from wf_roles,
           fnd_lookups
      where name = p_parameter
        and status = 'ACTIVE'
        and (expiration_date is null
             or sysdate < expiration_date)
        and lookup_type = 'FND_WF_ORIG_SYSTEMS'
        and lookup_code = orig_system;
  -- local variables
  l_proc                   varchar2(72) := g_package||'create_ame_action';
  l_action_id              number;
  l_effective_date         date;
  l_object_version_number  number;
  l_start_date             date;
  l_end_date               date;
  l_language_code          fnd_languages.language_code%TYPE;
  l_description            ame_actions.description%TYPE;
  l_action_type_name       ame_action_types.name%TYPE;
  l_approver               varchar2(100);
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Validate language code
  l_language_code := p_language_code;
  hr_api.validate_language_code(p_language_code => l_language_code);
  -- Set the effective date to the sysdate
  l_effective_date := sysdate;
  -- Issue a savepoint.
  --
  savepoint create_ame_action;
  --
  -- Call Before Process User Hook
  --
  begin
    ame_action_bk4.create_ame_action_b
      (p_language_code           => p_language_code
      ,p_action_type_id          => p_action_type_id
      ,p_parameter               => p_parameter
      ,p_parameter_two           => p_parameter_two
      ,p_description             => p_description
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_ame_action'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --generate description for substitution action type (seeded)
  --change made by srpurani
  l_description := p_description;
  open C_Sel1;
  fetch C_Sel1 into l_action_type_name;
  close C_Sel1;
  if(l_action_type_name = 'substitution') then
      open C_Sel2;
      fetch C_Sel2 into l_approver;
      if(C_Sel2 % NOTFOUND) then
        l_approver := 'Invalid approver';
      end if;
      close C_Sel2;
      fnd_message.set_name('PER', 'AME_400616_SUB_ACT_DESC');
      fnd_message.set_token('APPROVER', l_approver);
      l_description := fnd_message.get;
  end if;
  -- insert the row in ame_actions
  ame_act_ins.ins(p_effective_date        => l_effective_date,
                  p_action_type_id        => p_action_type_id,
                  p_parameter             => p_parameter,
                  p_parameter_two         => p_parameter_two,
                  p_description           => l_description,
                  p_action_id             => l_action_id,
                  p_object_version_number => l_object_version_number,
                  p_start_date            => l_start_date,
                  p_end_date              => l_end_date
                 );
  -- insert data into TL tables
  ame_acl_ins.ins_tl(p_language_code      => l_language_code
                    ,p_action_id          => l_action_id
                    ,p_description        => l_description
                    );
  -- Call after process user hook
  begin
    ame_action_bk4.create_ame_action_a
      (p_language_code           => p_language_code
      ,p_action_type_id          => p_action_type_id
      ,p_parameter               => p_parameter
      ,p_parameter_two           => p_parameter_two
      ,p_description             => p_description
      ,p_action_id               => l_action_id
      ,p_object_version_number   => l_object_version_number
      ,p_start_date              => l_start_date
      ,p_end_date                => l_end_date
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_ame_action'
        ,p_hook_type   => 'AP'
        );
  end;
  p_action_id              := l_action_id;
  p_object_version_number  := l_object_version_number;
  p_start_date             := l_start_date;
  p_end_date               := l_end_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 50);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_ame_action;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_action_id              := null;
    p_object_version_number  := null;
    p_start_date             := null;
    p_end_date               := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 60);
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    p_action_id              := null;
    p_object_version_number  := null;
    p_start_date             := null;
    p_end_date               := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 70);
    ROLLBACK TO create_ame_action;
    raise;
    --
end create_ame_action;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< update_ame_action_type_>-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_ame_action_type
  (p_validate                  in boolean default false,
   p_language_code             in varchar2 default hr_api.userenv_lang,
   p_action_type_id            in number,
   p_procedure_name            in varchar2 default hr_api.g_varchar2,
   p_description               in varchar2 default hr_api.g_varchar2,
   p_description_query         in varchar2 default hr_api.g_varchar2,
   p_object_version_number     in out nocopy number,
   p_start_date                out nocopy date,
   p_end_date                  out nocopy date
   ) is
  --
  -- Local variables
  --
  l_proc varchar2(72) :=   g_package||'update_ame_action_type';
  l_effective_date         date;
  l_object_version_number  number;
  l_start_date             date;
  l_end_date               date;
  l_language_code          fnd_languages.language_code%TYPE;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Validate language code
  l_language_code := p_language_code;
  hr_api.validate_language_code(p_language_code => l_language_code);
  -- Set the effective date to the sysdate
  l_effective_date := sysdate;
  l_object_version_number := p_object_version_number;
  -- Issue a savepoint.
  --
  savepoint update_ame_action_type;
  --
  -- Call Before Process User Hook
  begin
    ame_action_bk5.update_ame_action_type_b
      (p_language_code           => p_language_code
      ,p_action_type_id          => p_action_type_id
      ,p_procedure_name          => p_procedure_name
      ,p_description             => p_description
      ,p_description_query       => p_description_query
      ,p_object_version_number   => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_ame_action_type'
        ,p_hook_type   => 'BP'
        );
  end;
  -- Update action type.
  ame_aty_upd.upd(p_effective_date => l_effective_date,
                  p_datetrack_mode => hr_api.g_update,
                  p_action_type_id => p_action_type_id,
                  p_object_version_number => l_object_version_number,
                  p_procedure_name => p_procedure_name,
                  p_description => p_description,
                  p_description_query => p_description_query,
                  p_start_date => l_start_date,
                  p_end_date => l_end_date);
  -- Update TL Table
  ame_ayl_upd.upd_tl(p_language_code => p_language_code,
                     p_action_type_id => p_action_type_id,
                     p_description => p_description);
  -- Call After Process User Hook
  begin
    ame_action_bk5.update_ame_action_type_a
      (p_language_code           => p_language_code
      ,p_action_type_id          => p_action_type_id
      ,p_procedure_name          => p_procedure_name
      ,p_description             => p_description
      ,p_description_query       => p_description_query
      ,p_object_version_number   => l_object_version_number
      ,p_start_date              => l_start_date
      ,p_end_date                => l_end_date
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_ame_action_type'
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
  p_object_version_number := l_object_version_number;
  p_start_date := l_start_date;
  p_end_date := l_end_date;
  hr_utility.set_location(' Leaving:'||l_proc, 50);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO update_ame_action_type;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number := null;
    p_start_date := null;
    p_end_date := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 60);
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    --
    p_object_version_number := null;
    p_start_date := null;
    p_end_date := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 70);
    ROLLBACK TO update_ame_action_type;
    raise;
    --
end update_ame_action_type;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< update_ame_action_type_conf>-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_ame_action_type_conf
  (p_validate                      in boolean default false,
   p_action_type_id                in number,
   p_application_id                in number,
   p_voting_regime                 in varchar2 default hr_api.g_varchar2,
   p_chain_ordering_mode           in varchar2 default hr_api.g_varchar2,
   p_order_number                  in number   default hr_api.g_number,
   p_object_version_number         in out nocopy number,
   p_start_date                    out nocopy date,
   p_end_date                      out nocopy date
   ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) :=     g_package||'update_ame_action_type_conf';
  l_effective_date           date;
  l_object_version_number    number;
  l_start_date               date;
  l_end_date                 date;
  l_max_order_number         number;
  l_new_order_number         number;
  l_old_order_number         number;
  l_old_order_number_unique  varchar2(3);
  l_update_only_at_modified  boolean;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Set the effective date to the sysdate
  l_effective_date := sysdate;
  l_object_version_number := p_object_version_number;
  -- Issue a savepoint.
  --
  savepoint update_ame_action_type_conf;
  --
  -- Call Before Process User Hook
  begin
    ame_action_bk6.update_ame_action_type_conf_b
      (p_action_type_id          => p_action_type_id
      ,p_ame_application_id      => p_application_id
      ,p_voting_regime           => p_voting_regime
      ,p_order_number            => p_order_number
      ,p_chain_ordering_mode     => p_chain_ordering_mode
      ,p_object_version_number   => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_ame_action_type_conf'
        ,p_hook_type   => 'BP'
        );
  end;

  -- Update action type config details
  ame_acf_upd.upd(p_effective_date => l_effective_date
                 ,p_datetrack_mode => hr_api.g_update
                 ,p_application_id => p_application_id
                 ,p_action_type_id   => p_action_type_id
                 ,p_voting_regime => p_voting_regime
                 ,p_order_number => p_order_number
                 ,p_chain_ordering_mode => p_chain_ordering_mode
                 ,p_object_version_number  => l_object_version_number
                 ,p_start_date     => l_start_date
                 ,p_end_date       => l_end_date
                 );

  -- Call After Process User Hook
  begin
    ame_action_bk6.update_ame_action_type_conf_a
      (p_action_type_id          => p_action_type_id
      ,p_ame_application_id      => p_application_id
      ,p_voting_regime           => p_voting_regime
      ,p_order_number            => p_order_number
      ,p_chain_ordering_mode     => p_chain_ordering_mode
      ,p_object_version_number   => l_object_version_number
      ,p_start_date              => l_start_date
      ,p_end_date                => l_end_date
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_ame_action_type_conf'
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
  p_object_version_number := l_object_version_number;
  p_start_date := l_start_date;
  p_end_date := l_end_date;
  hr_utility.set_location(' Leaving:'||l_proc, 50);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO update_ame_action_type_conf;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number := null;
    p_start_date := null;
    p_end_date := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 60);
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    --
    p_object_version_number := null;
    p_start_date := null;
    p_end_date := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 70);
    ROLLBACK TO update_ame_action_type_conf;
    raise;
    --
end update_ame_action_type_conf;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< update_ame_action >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_ame_action
  (p_validate                  in boolean default false,
   p_language_code             in varchar2 default hr_api.userenv_lang,
   p_action_id                 in number,
   p_action_type_id            in number,
   p_parameter                 in varchar2 default hr_api.g_varchar2,
   p_parameter_two             in varchar2 default hr_api.g_varchar2,
   p_description               in varchar2 default hr_api.g_varchar2,
   p_object_version_number     in out nocopy number,
   p_start_date                out nocopy date,
   p_end_date                  out nocopy date
   ) is
  --
  -- Declare cursors and local variables
  --
   --cursors
  cursor C_Sel1 is
    select name
      from ame_action_types
      where action_type_id = p_action_type_id
        and sysdate between start_date and
               nvl(end_date - (1/86400), sysdate);
  cursor C_Sel2 is
    select meaning || ': ' || display_name
      from wf_roles,
           fnd_lookups
      where name = p_parameter
        and status = 'ACTIVE'
        and (expiration_date is null
             or sysdate < expiration_date)
        and lookup_type = 'FND_WF_ORIG_SYSTEMS'
        and lookup_code = orig_system;
  --
  l_proc varchar2(72) :=   g_package||'update_ame_action';
  l_effective_date         date;
  l_object_version_number  number;
  l_start_date             date;
  l_end_date               date;
  l_language_code          fnd_languages.language_code%TYPE;
  l_description            ame_actions.description%TYPE;
  l_action_type_name       ame_action_types.name%TYPE;
  l_approver               varchar2(100);
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Set the effective date to the sysdate
  l_effective_date := sysdate;
  l_object_version_number := p_object_version_number;
  -- Validate language code
  l_language_code := p_language_code;
  hr_api.validate_language_code(p_language_code => l_language_code);
  -- Issue a savepoint.
  --
  savepoint update_ame_action;
  --
  -- Call Before Process User Hook
  begin
    ame_action_bk7.update_ame_action_b
      (p_language_code           => p_language_code
      ,p_action_id               => p_action_id
      ,p_parameter               => p_parameter
      ,p_parameter_two           => p_parameter_two
      ,p_description             => p_description
      ,p_object_version_number   => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_ame_action'
        ,p_hook_type   => 'BP'
        );
  end;
  -- Update action.
  --generate description for substitution action type (seeded)
  --change made by srpurani
  l_description := p_description;
  open C_Sel1;
  fetch C_Sel1 into l_action_type_name;
  close C_Sel1;
  if(l_action_type_name = 'substitution') then
      open C_Sel2;
      fetch C_Sel2 into l_approver;
      if(C_Sel2 % NOTFOUND) then
        l_approver := 'Invalid approver';
      end if;
      close C_Sel2;
      fnd_message.set_name('PER', 'AME_400616_SUB_ACT_DESC');
      fnd_message.set_token('APPROVER', l_approver);
      l_description := fnd_message.get;
  end if;
  ame_act_upd.upd(p_effective_date => l_effective_date,
                  p_datetrack_mode => hr_api.g_update,
                  p_action_id => p_action_id,
                  p_action_type_id => p_action_type_id,
                  p_object_version_number => l_object_version_number,
                  p_parameter => p_parameter,
                  p_parameter_two => p_parameter_two,
                  p_description => l_description,
                  p_start_date => l_start_date,
                  p_end_date => l_end_date);
  -- update TL table
  ame_acl_upd.upd_tl(p_language_code => p_language_code,
                     p_action_id => p_action_id,
                     p_description => l_description);
  -- Call After Process User Hook
  begin
    ame_action_bk7.update_ame_action_a
      (p_language_code           => p_language_code
      ,p_action_id               => p_action_id
      ,p_parameter               => p_parameter
      ,p_parameter_two           => p_parameter_two
      ,p_description             => p_description
      ,p_object_version_number   => l_object_version_number
      ,p_start_date              => l_start_date
      ,p_end_date                => l_end_date
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_ame_action'
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
  p_object_version_number := l_object_version_number;
  p_start_date := l_start_date;
  p_end_date := l_end_date;
  hr_utility.set_location(' Leaving:'||l_proc, 50);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO update_ame_action;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number := null;
    p_start_date := null;
    p_end_date := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 60);
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    --
    p_object_version_number := null;
    p_start_date := null;
    p_end_date := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 70);
    ROLLBACK TO update_ame_action;
    raise;
    --
end update_ame_action;
--
-- ----------------------------------------------------------------------------
-- |--------------------< delete_ame_action_type >---------------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ame_action_type
  (p_validate                   in  boolean  default false
  ,p_action_type_id             in number
  ,p_object_version_number      in out nocopy number
  ,p_start_date                 out nocopy date
  ,p_end_date                   out nocopy date
  ) is
  --
  cursor req_attribute_cur(p_action_type_id in number,
                           p_effective_date in date) is
    select attribute_id, object_version_number
      from ame_mandatory_attributes
      where
        action_type_id = p_action_type_id
        and p_effective_date
        between start_date and nvl(end_date - ame_util.oneSecond, p_effective_date);
  cursor appr_type_usage_cur(p_action_type_id in number,
                             p_effective_date in date) is
    select approver_type_id, object_version_number
      from ame_approver_type_usages
      where
        action_type_id = p_action_type_id
        and p_effective_date
        between start_date and nvl(end_date - ame_util.oneSecond, p_effective_date);

  cursor action_type_usage_cur(p_action_type_id in number,
                               p_effective_date in date) is
    select rule_type, object_version_number
      from ame_action_type_usages
      where
        action_type_id = p_action_type_id
        and p_effective_date
        between start_date and nvl(end_date - ame_util.oneSecond, p_effective_date);
  cursor action_type_conf_cur(p_action_type_id in number,
                              p_effective_date in date) is
    select count(*)
      from ame_action_type_config
      where
        action_type_id = p_action_type_id
        and p_effective_date
        between start_date and nvl(end_date - ame_util.oneSecond, p_effective_date);
  cursor actions_cur(p_action_type_id in number,
                     p_effective_date in date) is
    select action_id, object_version_number
      from ame_actions
      where
        action_type_id = p_action_type_id
        and p_effective_date
        between start_date and nvl(end_date - ame_util.oneSecond, p_effective_date);
  cursor rule_usage_cur(p_action_type_id in number,
                     p_effective_date in date) is
    select count(*)
      from ame_action_usages ruleUsages
          ,ame_actions actions
          ,ame_action_types actionTypes
      where ruleUsages.action_id = actions.action_id
        and actions.action_type_id = actionTypes.action_type_id
        and actionTypes.action_type_id = p_action_type_id
        and p_effective_date
        between ruleUsages.start_date and nvl(ruleUsages.end_date - ame_util.oneSecond, p_effective_date)
        and p_effective_date
        between actions.start_date and nvl(actions.end_date - ame_util.oneSecond, p_effective_date)
        and p_effective_date
        between actionTypes.start_date and nvl(actionTypes.end_date - ame_util.oneSecond, p_effective_date);
  --
  l_proc                       varchar2(72) := g_package||'delete_ame_action_type';
  l_effective_date             date;
  l_man_attribute_ids          ame_util.idList;
  l_axu_rule_types             ame_util.idList;
  l_axu_object_version_number  number;
  l_axu_object_version_numbers ame_util.idList;
  l_axu_start_date             date;
  l_axu_end_date               date;
  l_man_object_version_number  number;
  l_man_object_version_numbers ame_util.idList;
  l_man_start_date             date;
  l_man_end_date               date;
  l_acf_object_version_number  number;
  l_acf_object_version_numbers ame_util.idList;
  l_acf_start_date             date;
  l_acf_end_date               date;
  l_application_ids            ame_util.idList;
  l_aty_object_version_number  number;
  l_aty_start_date             date;
  l_aty_end_date               date;
  l_apu_approver_type_ids      ame_util.idList;
  l_apu_object_version_number  number;
  l_apu_object_version_numbers ame_util.idList;
  l_apu_start_date             date;
  l_apu_end_date               date;
  l_rule_types                 ame_util.idList;
  l_effective_date2            date;
  l_config_count               number;
  l_rule_usage_count           number;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  -- Issue a savepoint.
  --
  -- Set the effective date to the sysdate
  l_effective_date := sysdate;
  l_aty_object_version_number := p_object_version_number;
  savepoint delete_ame_action_type;
  --
  -- Process Logic
  -- Call DBMS_UTILITY.FORMAT_CALL_STACK to check if the call has been made from the 'AME_ACTION_SWI' package.
  --if (instrb(DBMS_UTILITY.FORMAT_CALL_STACK,'AME_ACTION_SWI') = 0) then
    -- Remove action type configs
    Open action_type_conf_cur(p_action_type_id => p_action_type_id,
                               p_effective_date => l_effective_date);
    Fetch action_type_conf_cur into l_config_count;
    Close action_type_conf_cur;
    if(l_config_count <> 0) then
      fnd_message.set_name('PER', 'AME_400608_ACT_TYP_CONF_EXISTS');
      fnd_message.raise_error;
    end if;
    open rule_usage_cur(p_action_type_id => p_action_type_id,
                         p_effective_date => l_effective_date);
    fetch rule_usage_cur into l_rule_usage_count;
    close rule_usage_cur;
    if(l_rule_usage_count <> 0) then
      fnd_message.set_name('PER', 'AME_400609_ACT_USG_EXISTS');
      fnd_message.raise_error;
    end if;
    -- Remove action type usages
    Open action_type_usage_cur(p_action_type_id => p_action_type_id,
                               p_effective_date => l_effective_date);
    Fetch action_type_usage_cur bulk collect
      Into l_rule_types,
           l_axu_object_version_numbers;
    Close action_type_usage_cur;
    for i in 1 .. l_rule_types.count loop
      l_axu_object_version_number := l_axu_object_version_numbers(i);
      delete_ame_action_type_usage(p_validate => p_validate,
                                   p_action_type_id => p_action_type_id,
                                   p_rule_type => l_rule_types(i),
                                   p_object_version_number => l_axu_object_version_number,
                                   p_start_date => l_axu_start_date,
                                   p_end_date => l_axu_end_date);
    end loop;
    -- Remove required attributes
    Open req_attribute_cur(p_action_type_id => p_action_type_id,
                           p_effective_date => l_effective_date);
      Fetch req_attribute_cur bulk collect
        Into l_man_attribute_ids,
             l_man_object_version_numbers;
    Close req_attribute_cur;
    for i in 1 .. l_man_attribute_ids.count loop
      l_man_object_version_number := l_man_object_version_numbers(i);
      delete_ame_req_attribute(p_validate => p_validate,
                               p_action_type_id => p_action_type_id,
                               p_attribute_id => l_man_attribute_ids(i),
                               p_object_version_number => l_man_object_version_number,
                               p_start_date => l_man_start_date,
                               p_end_date => l_man_end_date);
    end loop;
    -- Remove approver type usages
    Open appr_type_usage_cur(p_action_type_id => p_action_type_id,
                             p_effective_date => l_effective_date);
      Fetch appr_type_usage_cur bulk collect
        Into l_apu_approver_type_ids,
             l_apu_object_version_numbers;
    Close appr_type_usage_cur;
    for i in 1 .. l_apu_approver_type_ids.count loop
      l_apu_object_version_number := l_apu_object_version_numbers(i);
      delete_ame_appr_type_usage(p_validate => p_validate,
                                 p_action_type_id => p_action_type_id,
                                 p_approver_type_id => l_apu_approver_type_ids(i),
                                 p_object_version_number => l_apu_object_version_number,
                                 p_start_date => l_apu_start_date,
                                 p_end_date => l_apu_end_date);
    end loop;
    --Remove actions
    Open actions_cur(p_action_type_id => p_action_type_id,
                            p_effective_date => l_effective_date);
      Fetch actions_cur bulk collect
        Into l_apu_approver_type_ids,
             l_apu_object_version_numbers;
    Close actions_cur;
    for i in 1 .. l_apu_approver_type_ids.count loop
      l_apu_object_version_number := l_apu_object_version_numbers(i);
      delete_ame_action(p_validate               => p_validate
                       ,p_action_id              => l_apu_approver_type_ids(i)
                       ,p_action_type_id         => p_action_type_id
                       ,p_object_version_number  => l_apu_object_version_number
                       ,p_start_date             => l_apu_start_date
                       ,p_end_date               => l_apu_end_date
                       );
    end loop;
  --end if;
  -- Call Before Process User Hook
  begin
    ame_action_bk8.delete_ame_action_type_b
      (p_action_type_id          => p_action_type_id
      ,p_object_version_number   => p_object_version_number
      );
    exception
      when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_ame_action_type'
        ,p_hook_type   => 'BP'
        );
  end;
  -- Remove action type
  l_effective_date2 := sysdate;
  ame_aty_del.del
    (p_action_type_id => p_action_type_id,
     p_datetrack_mode => hr_api.g_delete,
     p_object_version_number => l_aty_object_version_number,
     p_effective_date => l_effective_date2,
     p_start_date => l_aty_start_date,
     p_end_date => l_aty_end_date);
  -- Call After Process User Hook
  begin
    ame_action_bk8.delete_ame_action_type_a
      (p_action_type_id          => p_action_type_id
      ,p_object_version_number   => l_aty_object_version_number
      ,p_start_date              => l_aty_start_date
      ,p_end_date                => l_aty_end_date
      );
    exception
      when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_ame_action_type'
        ,p_hook_type   => 'AP'
        );
  end;
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  p_object_version_number := l_aty_object_version_number;
  p_start_date := l_aty_start_date;
  p_end_date := l_aty_end_date;
  hr_utility.set_location(' Leaving:'||l_proc, 50);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO delete_ame_action_type;
    --
    p_object_version_number := null;
    p_start_date := null;
    p_end_date := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 60);
  when others then
    --
    -- A validation or unexpected error has occurred
    p_object_version_number := null;
    p_start_date := null;
    p_end_date := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 70);
    ROLLBACK TO delete_ame_action_type;
    raise;
    --
    -- End of fix.
    --
end delete_ame_action_type;
--
-- ----------------------------------------------------------------------------
-- |--------------------< delete_ame_action_type_usage >------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ame_action_type_usage
  (p_validate                       in     boolean  default false
  ,p_action_type_id                 in     number
  ,p_rule_type                      in     number
  ,p_object_version_number          in out nocopy number
  ,p_start_date                     out nocopy date
  ,p_end_date                       out nocopy date
  ) is
  --
  l_proc                  varchar2(72) := g_package||'delete_ame_action_type_usage';
  l_effective_date        date;
  l_object_version_number number;
  l_start_date            date;
  l_end_date              date;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Set the effective date to the sysdate
  l_effective_date := sysdate;
  l_object_version_number := p_object_version_number;
  -- Issue a savepoint.
  --
  savepoint delete_ame_action_type_usage;
  -- Remove action type usage
  begin
    ame_action_bk15.delete_ame_action_type_usage_b
      (p_action_type_id          => p_action_type_id
      ,p_rule_type               => p_rule_type
      ,p_object_version_number   => l_object_version_number
        );
    exception
      when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error
          (p_module_name => 'delete_ame_action_type_usage'
          ,p_hook_type   => 'BP'
          );
  end;
  ame_axu_del.del
    (p_action_type_id  => p_action_type_id,
     p_rule_type => p_rule_type,
     p_datetrack_mode => hr_api.g_delete,
     p_object_version_number => l_object_version_number,
     p_effective_date => l_effective_date,
     p_start_date => l_start_date,
     p_end_date => l_end_date);
    -- Call Before Process User Hook
  begin
    ame_action_bk15.delete_ame_action_type_usage_a
      (p_action_type_id => p_action_type_id
      ,p_rule_type => p_rule_type
      ,p_object_version_number => l_object_version_number
      ,p_start_date => l_start_date
      ,p_end_date => l_end_date
      );
    exception
      when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error
          (p_module_name => 'delete_ame_action_type_usage'
          ,p_hook_type   => 'AP'
          );
  end;
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  p_object_version_number := l_object_version_number;
  p_start_date := l_start_date;
  p_end_date := l_end_date;
  hr_utility.set_location(' Leaving:'||l_proc, 50);
exception
  when hr_api.validate_enabled then
    --
    p_object_version_number := null;
    p_start_date := null;
    p_end_date := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 60);
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO delete_ame_action_type_usage;
    --
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    p_object_version_number := null;
    p_start_date := null;
    p_end_date := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 70);
    ROLLBACK TO delete_ame_action_type_usage;
    raise;
    --
end delete_ame_action_type_usage;
--
-- ----------------------------------------------------------------------------
-- |--------------------< delete_ame_action_type_conf >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ame_action_type_conf
  (p_validate                       in     boolean  default false
  ,p_action_type_id                 in     number
  ,p_application_id                 in     number
  ,p_object_version_number          in out nocopy number
  ,p_start_date                     out nocopy date
  ,p_end_date                       out nocopy date
  ) is
  --
  l_proc                  varchar2(72) := g_package||'delete_ame_action_type_conf';
  l_effective_date        date;
  l_object_version_number number;
  l_start_date            date;
  l_end_date              date;
  l_order_number          number;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Set the effective date to the sysdate
  l_effective_date := sysdate;
  l_object_version_number := p_object_version_number;
  -- Issue a savepoint.
  --
  savepoint delete_ame_action_type_conf;
  -- Remove action type configuration

  -- Call Before Process User Hook
  begin
    ame_action_bk14.delete_ame_action_type_conf_b
      (p_action_type_id          => p_action_type_id
      ,p_ame_application_id      => p_application_id
      ,p_object_version_number   => l_object_version_number
      );
    exception
      when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error
          (p_module_name => 'delete_ame_action_type_conf'
          ,p_hook_type   => 'BP'
          );
  end;
  ame_acf_del.del
    (p_action_type_id  => p_action_type_id,
     p_application_id => p_application_id,
     p_datetrack_mode => hr_api.g_delete,
     p_object_version_number => l_object_version_number,
     p_effective_date => l_effective_date,
     p_start_date => l_start_date,
     p_end_date => l_end_date);
    -- Call After Process User Hook
  begin
    ame_action_bk14.delete_ame_action_type_conf_a
      (p_action_type_id          => p_action_type_id
      ,p_ame_application_id      => p_application_id
      ,p_object_version_number   => l_object_version_number
      ,p_start_date => l_start_date
      ,p_end_date => l_end_date
      );
    exception
      when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error
          (p_module_name => 'delete_ame_action_type_conf'
          ,p_hook_type   => 'AP'
          );
  end;
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  p_object_version_number := l_object_version_number;
  p_start_date := l_start_date;
  p_end_date := l_end_date;
  hr_utility.set_location(' Leaving:'||l_proc, 50);
exception
  when hr_api.validate_enabled then
    --
    p_object_version_number := null;
    p_start_date := null;
    p_end_date := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 60);
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO delete_ame_action_type_conf;
    --
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    p_object_version_number := null;
    p_start_date := null;
    p_end_date := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 70);
    ROLLBACK TO delete_ame_action_type_conf;
    raise;
    --
end delete_ame_action_type_conf;
-- ----------------------------------------------------------------------------
-- |--------------------< delete_ame_appr_type_usage >------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ame_appr_type_usage
  (p_validate                       in     boolean  default false
  ,p_action_type_id                 in     number
  ,p_approver_type_id               in     number
  ,p_object_version_number          in out nocopy number
  ,p_start_date                     out nocopy date
  ,p_end_date                       out nocopy date
  ) is
  --
  --
  l_proc                   varchar2(72) := g_package||'delete_ame_appr_type_usage';
  l_effective_date         date;
  l_object_version_number  number;
  l_start_date             date;
  l_end_date               date;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Set the effective date to the sysdate
  l_effective_date := sysdate;
  l_object_version_number := p_object_version_number;
  -- Issue a savepoint.
  --
  savepoint delete_ame_appr_type_usage;
  --
  -- Call Before Process User Hook
  begin
    ame_action_bk9.delete_ame_appr_type_usage_b
      (p_action_type_id         => p_action_type_id
      ,p_approver_type_id       => p_approver_type_id
      ,p_object_version_number  => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_ame_appr_type_usage'
        ,p_hook_type   => 'BP'
        );
  end;
  hr_utility.set_location(l_proc, 7);
  --
  ame_apu_del.del
    (p_action_type_id  => p_action_type_id,
     p_approver_type_id => p_approver_type_id,
     p_datetrack_mode => hr_api.g_delete,
     p_object_version_number => l_object_version_number,
     p_effective_date => l_effective_date,
     p_start_date => l_start_date,
     p_end_date => l_end_date);
  -- Call After Process User Hook
  begin
    ame_action_bk9.delete_ame_appr_type_usage_a
      (p_action_type_id         => p_action_type_id
      ,p_approver_type_id       => p_approver_type_id
      ,p_object_version_number  => l_object_version_number
      ,p_start_date             => l_start_date
      ,p_end_date               => l_end_date
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_ame_appr_type_usage'
        ,p_hook_type   => 'AP'
        );
  end;
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  p_object_version_number := l_object_version_number;
  p_start_date := l_start_date;
  p_end_date := l_end_date;
  hr_utility.set_location(' Leaving:'||l_proc, 50);
exception
  when hr_api.validate_enabled then
    --
    p_object_version_number := null;
    p_start_date := null;
    p_end_date := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 60);
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO delete_ame_appr_type_usage;
    --
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    p_object_version_number := null;
    p_start_date := null;
    p_end_date := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 70);
    ROLLBACK TO delete_ame_appr_type_usage;
    raise;
    --
end delete_ame_appr_type_usage;
--
-- VERIFY IN HANDLER THAT SEEDED REQUIRED ATTRIBUTES CANNOT BE DELETED!!
-- ----------------------------------------------------------------------------
-- |--------------------< delete_ame_req_attribute >------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ame_req_attribute
  (p_validate                   in     boolean  default false
  ,p_action_type_id             in     number
  ,p_attribute_id               in     number
  ,p_object_version_number      in out nocopy number
  ,p_start_date                 out nocopy date
  ,p_end_date                   out nocopy date
  ) is
  --
  l_proc                  varchar2(72) := g_package||'delete_ame_req_attribute';
  l_effective_date        date;
  l_object_version_number number;
  l_start_date            date;
  l_end_date              date;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Set the effective date to the sysdate
  l_effective_date := sysdate;
  l_object_version_number := p_object_version_number;
  -- Issue a savepoint.
  --
  savepoint delete_ame_req_attribute;
  -- Call Before Process User Hook
  begin
    ame_action_bk10.delete_ame_req_attribute_b
      (p_action_type_id         => p_action_type_id
      ,p_attribute_id           => p_attribute_id
      ,p_object_version_number  => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_ame_req_attribute'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  ame_man_del.del
    (p_action_type_id  => p_action_type_id,
     p_attribute_id => p_attribute_id,
     p_datetrack_mode => hr_api.g_delete,
     p_object_version_number => l_object_version_number,
     p_effective_date => l_effective_date,
     p_start_date => l_start_date,
     p_end_date => l_end_date);
  -- Call After Process User Hook
  begin
    ame_action_bk10.delete_ame_req_attribute_a
      (p_action_type_id         => p_action_type_id
      ,p_attribute_id           => p_attribute_id
      ,p_object_version_number  => l_object_version_number
      ,p_start_date             => l_start_date
      ,p_end_date               => l_end_date
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_ame_req_attribute'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  p_object_version_number := l_object_version_number;
  p_start_date := l_start_date;
  p_end_date := l_end_date;
  hr_utility.set_location(' Leaving:'||l_proc, 50);
exception
  when hr_api.validate_enabled then
    --
    p_object_version_number := null;
    p_start_date := null;
    p_end_date   := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 60);
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO delete_ame_req_attribute;
    --
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    p_object_version_number := null;
    p_start_date := null;
    p_end_date   := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 70);
    ROLLBACK TO delete_ame_req_attribute;
    raise;
    --
end delete_ame_req_attribute;
--
-- ----------------------------------------------------------------------------
-- |--------------------< delete_ame_action >------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ame_action
  (p_validate                       in     boolean  default false
  ,p_action_id                      in     number
  ,p_action_type_id                 in     number
  ,p_object_version_number          in out nocopy number
  ,p_start_date                     out nocopy date
  ,p_end_date                       out nocopy date
  ) is
  --
  --
  l_proc                  varchar2(72) := g_package||'delete_ame_action';
  l_effective_date        date;
  l_object_version_number number;
  l_start_date            date;
  l_end_date              date;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Set the effective date to the sysdate
  l_effective_date := sysdate;
  l_object_version_number := p_object_version_number;
  -- Issue a savepoint.
  --
  savepoint delete_ame_action;
  -- Call Before Process User Hook
  begin
    ame_action_bk11.delete_ame_action_b
      (p_action_id              => p_action_id
      ,p_object_version_number  => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_ame_action'
        ,p_hook_type   => 'BP'
        );
  end;
  hr_utility.set_location(l_proc, 7);
  -- Process Logic
  ame_act_del.del
    (p_action_id  => p_action_id,
     p_action_type_id => p_action_type_id,
     p_datetrack_mode => hr_api.g_delete,
     p_object_version_number => l_object_version_number,
     p_effective_date => l_effective_date,
     p_start_date => l_start_date,
     p_end_date => l_end_date);
  -- Call After Process User Hook
  begin
    ame_action_bk11.delete_ame_action_a
      (p_action_id              => p_action_id
      ,p_object_version_number  => l_object_version_number
      ,p_start_date             => l_start_date
      ,p_end_date               => l_end_date
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_ame_action'
        ,p_hook_type   => 'AP'
        );
  end;
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  p_object_version_number := l_object_version_number;
  p_start_date := l_start_date;
  p_end_date := l_end_date;
  hr_utility.set_location(' Leaving:'||l_proc, 50);
exception
  when hr_api.validate_enabled then
    --
    p_object_version_number := null;
    p_start_date := null;
    p_end_date := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 60);
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO delete_ame_action;
    --
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    p_object_version_number := null;
    p_start_date := null;
    p_end_date := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 70);
    ROLLBACK TO delete_ame_action;
    raise;
    --
end delete_ame_action;
end ame_action_api;

/
