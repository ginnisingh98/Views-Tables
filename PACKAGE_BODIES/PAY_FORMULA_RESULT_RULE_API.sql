--------------------------------------------------------
--  DDL for Package Body PAY_FORMULA_RESULT_RULE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_FORMULA_RESULT_RULE_API" as
/* $Header: pyfrrapi.pkb 120.0 2005/05/29 05:06:01 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  PAY_FORMULA_RESULT_RULE_API.';
--
-- ----------------------------------------------------------------------------
-- |----------------------< CREATE_FORMULA_RESULT_RULE >----------------------|
-- ----------------------------------------------------------------------------
--
procedure CREATE_FORMULA_RESULT_RULE
  (p_validate                    in     boolean   default false
  ,p_effective_date              in     date
  ,p_status_processing_rule_id   in     number
  ,p_result_name                 in     varchar2
  ,p_result_rule_type            in     varchar2
  ,p_business_group_id           in     number    default null
  ,p_legislation_code            in     varchar2  default null
  ,p_element_type_id             in     number    default null
  ,p_legislation_subgroup        in     varchar2  default null
  ,p_severity_level              in     varchar2  default null
  ,p_input_value_id              in     number    default null
  ,p_formula_result_rule_id         out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                 varchar2(72):=g_package||'CREATE_FORMULA_RESULT_RULE';
  l_effective_date          date;
  l_effective_start_date    date;
  l_effective_end_date      date;
  l_formula_result_rule_id  number;
  l_object_version_number   number;
  l_element_type_id         pay_status_processing_rules_f.element_type_id%type;
  --
  cursor c_spr_element is
    select element_type_id
      from pay_status_processing_rules_f spr
     where spr.status_processing_rule_id = p_status_processing_rule_id
       and p_effective_date between spr.effective_start_date
       and spr.effective_end_date;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint CREATE_FORMULA_RESULT_RULE;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  --
  -- Call Before Process User Hook
  --
  begin
    PAY_FORMULA_RESULT_RULE_bk1.CREATE_FORMULA_RESULT_RULE_b
      (p_effective_date             =>  l_effective_date
      ,p_status_processing_rule_id  =>  p_status_processing_rule_id
      ,p_result_name                =>  p_result_name
      ,p_result_rule_type           =>  p_result_rule_type
      ,p_business_group_id          =>  p_business_group_id
      ,p_legislation_code           =>  p_legislation_code
      ,p_element_type_id            =>  p_element_type_id
      ,p_legislation_subgroup       =>  p_legislation_subgroup
      ,p_severity_level             =>  p_severity_level
      ,p_input_value_id             =>  p_input_value_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_FORMULA_RESULT_RULE'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  if p_result_rule_type = 'D' then
    --
    -- default the element type for direct result rule.
    --
    open c_spr_element;
    fetch c_spr_element into l_element_type_id;
    close c_spr_element;
    --
  else
    l_element_type_id := p_element_type_id;
  end if;
  --
  -- Process Logic
  --
  pay_frr_ins.ins
    (p_effective_date             =>  l_effective_date
    ,p_status_processing_rule_id  =>  p_status_processing_rule_id
    ,p_result_name                =>  p_result_name
    ,p_result_rule_type           =>  p_result_rule_type
    ,p_business_group_id          =>  p_business_group_id
    ,p_legislation_code           =>  p_legislation_code
    ,p_element_type_id            =>  l_element_type_id
    ,p_legislation_subgroup       =>  p_legislation_subgroup
    ,p_severity_level             =>  p_severity_level
    ,p_input_value_id             =>  p_input_value_id
    ,p_formula_result_rule_id     =>  l_formula_result_rule_id
    ,p_object_version_number      =>  l_object_version_number
    ,p_effective_start_date       =>  l_effective_start_date
    ,p_effective_end_date         =>  l_effective_end_date
    );
  --
  -- Call After Process User Hook
  --
  begin
    PAY_FORMULA_RESULT_RULE_bk1.CREATE_FORMULA_RESULT_RULE_a
      (p_effective_date             =>  l_effective_date
      ,p_status_processing_rule_id  =>  p_status_processing_rule_id
      ,p_result_name                =>  p_result_name
      ,p_result_rule_type           =>  p_result_rule_type
      ,p_business_group_id          =>  p_business_group_id
      ,p_legislation_code           =>  p_legislation_code
      ,p_element_type_id            =>  l_element_type_id
      ,p_legislation_subgroup       =>  p_legislation_subgroup
      ,p_severity_level             =>  p_severity_level
      ,p_input_value_id             =>  p_input_value_id
      ,p_formula_result_rule_id     =>  l_formula_result_rule_id
      ,p_effective_start_date       =>  l_effective_start_date
      ,p_effective_end_date         =>  l_effective_end_date
      ,p_object_version_number      =>  l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_FORMULA_RESULT_RULE'
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
  -- Set all output arguments
  --
  p_formula_result_rule_id      := l_formula_result_rule_id;
  p_effective_start_date        := l_effective_start_date;
  p_effective_end_date          := l_effective_end_date;
  p_object_version_number       := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to CREATE_FORMULA_RESULT_RULE;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_formula_result_rule_id      := null;
    p_object_version_number       := null;
    p_effective_start_date        := null;
    p_effective_end_date          := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to CREATE_FORMULA_RESULT_RULE;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_formula_result_rule_id      := null;
    p_object_version_number       := null;
    p_effective_start_date        := null;
    p_effective_end_date          := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
    --
End CREATE_FORMULA_RESULT_RULE;
--
-- ----------------------------------------------------------------------------
-- |----------------------< UPDATE_FORMULA_RESULT_RULE >----------------------|
-- ----------------------------------------------------------------------------
--
procedure UPDATE_FORMULA_RESULT_RULE
  (p_validate                    in     boolean   default false
  ,p_effective_date              in     date
  ,p_datetrack_update_mode       in     varchar2
  ,p_formula_result_rule_id      in     number
  ,p_object_version_number       in out nocopy number
  ,p_result_rule_type            in     varchar2  default hr_api.g_varchar2
  ,p_element_type_id             in     number    default hr_api.g_number
  ,p_severity_level              in     varchar2  default hr_api.g_varchar2
  ,p_input_value_id              in     number    default hr_api.g_number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                 varchar2(72):=g_package||'UPDATE_FORMULA_RESULT_RULE';
  l_effective_date          date;
  l_effective_start_date    date;
  l_effective_end_date      date;
  l_object_version_number   number;
  l_element_type_id         pay_status_processing_rules_f.element_type_id%type;
  --
  cursor c_spr_element is
    select spr.element_type_id
      from pay_formula_result_rules_f frr
          ,pay_status_processing_rules_f spr
     where frr.formula_result_rule_id = p_formula_result_rule_id
       and spr.status_processing_rule_id = frr.status_processing_rule_id
       and p_effective_date between frr.effective_start_date
       and frr.effective_end_date;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint UPDATE_FORMULA_RESULT_RULE;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date        := trunc(p_effective_date);
  --
  -- Remember IN OUT parameter IN values
  --
  l_object_version_number := p_object_version_number;
  --
  -- Call Before Process User Hook
  --
  begin
    PAY_FORMULA_RESULT_RULE_bk2.UPDATE_FORMULA_RESULT_RULE_b
      (p_effective_date          =>  l_effective_date
      ,p_datetrack_update_mode   =>  p_datetrack_update_mode
      ,p_formula_result_rule_id  =>  p_formula_result_rule_id
      ,p_object_version_number   =>  l_object_version_number
      ,p_result_rule_type        =>  p_result_rule_type
      ,p_element_type_id         =>  p_element_type_id
      ,p_severity_level          =>  p_severity_level
      ,p_input_value_id          =>  p_input_value_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_FORMULA_RESULT_RULE'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  if p_result_rule_type = 'D' then
    --
    -- default the element type for direct result rule.
    --
    open c_spr_element;
    fetch c_spr_element into l_element_type_id;
    close c_spr_element;
    --
  else
    l_element_type_id := p_element_type_id;
  end if;
  --
  -- Process Logic
  --
  pay_frr_upd.upd
    (p_effective_date             =>  l_effective_date
    ,p_datetrack_mode             =>  p_datetrack_update_mode
    ,p_formula_result_rule_id     =>  p_formula_result_rule_id
    ,p_object_version_number      =>  l_object_version_number
    ,p_result_rule_type           =>  p_result_rule_type
    ,p_element_type_id            =>  l_element_type_id
    ,p_severity_level             =>  p_severity_level
    ,p_input_value_id             =>  p_input_value_id
    ,p_effective_start_date       =>  l_effective_start_date
    ,p_effective_end_date         =>  l_effective_end_date
    );
  --
  -- Call After Process User Hook
  --
  begin
    PAY_FORMULA_RESULT_RULE_bk2.UPDATE_FORMULA_RESULT_RULE_a
      (p_effective_date             =>  l_effective_date
      ,p_datetrack_update_mode      =>  p_datetrack_update_mode
      ,p_result_rule_type           =>  p_result_rule_type
      ,p_element_type_id            =>  l_element_type_id
      ,p_severity_level             =>  p_severity_level
      ,p_input_value_id             =>  p_input_value_id
      ,p_formula_result_rule_id     =>  p_formula_result_rule_id
      ,p_effective_start_date       =>  l_effective_start_date
      ,p_effective_end_date         =>  l_effective_end_date
      ,p_object_version_number      =>  l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_FORMULA_RESULT_RULE'
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
  -- Set all output arguments
  --
  p_effective_start_date        := l_effective_start_date;
  p_effective_end_date          := l_effective_end_date;
  p_object_version_number       := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to UPDATE_FORMULA_RESULT_RULE;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number       := l_object_version_number;
    p_effective_start_date        := null;
    p_effective_end_date          := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to UPDATE_FORMULA_RESULT_RULE;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_object_version_number       := l_object_version_number;
    p_effective_start_date        := null;
    p_effective_end_date          := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
    --
End UPDATE_FORMULA_RESULT_RULE;
--
-- ----------------------------------------------------------------------------
-- |----------------------< DELETE_FORMULA_RESULT_RULE >----------------------|
-- ----------------------------------------------------------------------------
--
procedure DELETE_FORMULA_RESULT_RULE
  (p_validate                    in     boolean   default false
  ,p_effective_date              in     date
  ,p_datetrack_delete_mode       in     varchar2
  ,p_formula_result_rule_id      in     number
  ,p_object_version_number       in out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                 varchar2(72):=g_package||'DELETE_FORMULA_RESULT_RULE';
  l_effective_date          date;
  l_effective_start_date    date;
  l_effective_end_date      date;
  l_object_version_number   number;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint DELETE_FORMULA_RESULT_RULE;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date        := trunc(p_effective_date);
  --
  -- Remember IN OUT parameter IN values
  --
  l_object_version_number := p_object_version_number;
  --
  -- Call Before Process User Hook
  --
  begin
    PAY_FORMULA_RESULT_RULE_bk3.DELETE_FORMULA_RESULT_RULE_b
      (p_effective_date          =>  l_effective_date
      ,p_datetrack_delete_mode   =>  p_datetrack_delete_mode
      ,p_formula_result_rule_id  =>  p_formula_result_rule_id
      ,p_object_version_number   =>  l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_FORMULA_RESULT_RULE'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --

  --
  -- Process Logic
  --
  pay_frr_del.del
    (p_effective_date             =>  l_effective_date
    ,p_datetrack_mode             =>  p_datetrack_delete_mode
    ,p_formula_result_rule_id     =>  p_formula_result_rule_id
    ,p_object_version_number      =>  l_object_version_number
    ,p_effective_start_date       =>  l_effective_start_date
    ,p_effective_end_date         =>  l_effective_end_date
    );
  --
  -- Call After Process User Hook
  --
  begin
    PAY_FORMULA_RESULT_RULE_bk3.DELETE_FORMULA_RESULT_RULE_a
      (p_effective_date             =>  l_effective_date
      ,p_datetrack_delete_mode      =>  p_datetrack_delete_mode
      ,p_formula_result_rule_id     =>  p_formula_result_rule_id
      ,p_effective_start_date       =>  l_effective_start_date
      ,p_effective_end_date         =>  l_effective_end_date
      ,p_object_version_number      =>  l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_FORMULA_RESULT_RULE'
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
  -- Set all output arguments
  --
  p_effective_start_date        := l_effective_start_date;
  p_effective_end_date          := l_effective_end_date;
  p_object_version_number       := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to DELETE_FORMULA_RESULT_RULE;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number       := l_object_version_number;
    p_effective_start_date        := null;
    p_effective_end_date          := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to DELETE_FORMULA_RESULT_RULE;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_object_version_number       := l_object_version_number;
    p_effective_start_date        := null;
    p_effective_end_date          := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
    --
End DELETE_FORMULA_RESULT_RULE;
--

end PAY_FORMULA_RESULT_RULE_API;

/
