--------------------------------------------------------
--  DDL for Package Body HR_PAY_SCALE_VALUE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PAY_SCALE_VALUE_API" as
/* $Header: pypsrapi.pkb 115.6 2003/06/24 19:35:36 ynegoro ship $ */
--
cursor csr_get_rate_type
   (p_grade_rule_id  number
   ,p_effective_date date
   ) is
  select grr.rate_type
  from   pay_grade_rules_f grr
  where  grr.grade_rule_id = p_grade_rule_id
  and    p_effective_date  between grr.effective_start_date
                           and     grr.effective_end_date;
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_pay_scale_value_api.';
--
procedure check_rate_type
  (p_grade_rule_id  in number
  ,p_effective_date in date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_rate_type             pay_grade_rules_f.rate_type%TYPE;
  l_proc                  varchar2(72) := g_package||'check_rate_type';
  --
  cursor csr_get_rate_type is
    select grr.rate_type
    from   pay_grade_rules_f grr
    where  grr.grade_rule_id = p_grade_rule_id
    and    p_effective_date  between grr.effective_start_date
                             and     grr.effective_end_date;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Check that the Grade Rule identified is for a Grade Rate.
  --
  open  csr_get_rate_type;
  fetch csr_get_rate_type
   into l_rate_type;
  if csr_get_rate_type%notfound then
    --
    close csr_get_rate_type;
    --
    hr_utility.set_location(l_proc, 7);
    --
    hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
    hr_utility.raise_error;
    --
  else
    --
    close csr_get_rate_type;
    --
    if l_rate_type <> 'SP' then
      --
      hr_utility.set_location(l_proc, 8);
      --
      hr_utility.set_message(801, 'HR_7855_GRR_INV_NOT_SP_RATE_TY');
      hr_utility.raise_error;
      --
    end if;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 11);
end;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_pay_scale_value >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_pay_scale_value
  (p_validate                      in            boolean  default false
  ,p_effective_date                in            date
  ,p_rate_id                       in            number
  ,p_currency_code                 in            varchar2
  ,p_spinal_point_id               in            number
  ,p_value                         in            varchar2 default null
  ,p_grade_rule_id                    out nocopy number
  ,p_object_version_number            out nocopy number
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'create_pay_scale_value';
  l_business_group_id   pay_grade_rules_f.business_group_id%TYPE;
  l_sequence            pay_grade_rules_f.sequence%TYPE;
  l_effective_date      date;
  l_grade_rule_id                 number;
  l_object_version_number         number;
  l_effective_start_date          date;
  l_effective_end_date            date;
  --
  cursor csr_get_der_args is
  select spo.business_group_id,
         spo.sequence
    from per_spinal_points spo
   where spo.spinal_point_id = p_spinal_point_id;
  --
begin
  --
  -- Set l_effective_date equal to truncated version of p_effective_date for
  -- API work. Stops dates being passed to row handlers with time portion.
  --
  l_effective_date := trunc(p_effective_date);
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint.
  --
  savepoint create_pay_scale_value;
  hr_utility.set_location(l_proc, 6);
  --
  -- Check that p_spinal_point_id is not null as it is used in the cursor.
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'spinal_point_id',
     p_argument_value => p_spinal_point_id);
  --
  -- Get business_group_id using person_id.
  --
  open  csr_get_der_args;
  fetch csr_get_der_args
   into l_business_group_id,
        l_sequence;
  --
  if csr_get_der_args%notfound then
    close csr_get_der_args;
    hr_utility.set_message(801, 'HR_7312_GRR_INVALID_SPNL_POINT');
    hr_utility.raise_error;
  end if;
  --
  close csr_get_der_args;
  --
  --
  --
  hr_utility.set_location(l_proc, 7);
  --
  -- Insert Progression Point Value.
  --
hr_rate_values_api.create_rate_value(
     p_validate                     => FALSE
    ,p_effective_date               => l_effective_date
    ,p_business_group_id            => l_business_group_id
    ,p_rate_id                      => p_rate_id
    ,p_grade_or_spinal_point_id     => p_spinal_point_id
    ,p_rate_type                    => 'SP'
    ,p_currency_code                => p_currency_code
    ,p_value                        => p_value
    ,p_grade_rule_id                => l_grade_rule_id
    ,p_object_version_number        => l_object_version_number
    ,p_effective_start_date         => l_effective_start_date
    ,p_effective_end_date           => l_effective_end_date
    );
  --
  hr_utility.set_location(l_proc, 8);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set out parms.
  --
  p_grade_rule_id                 := l_grade_rule_id;
  p_object_version_number         := l_object_version_number;
  p_effective_start_date          := l_effective_start_date;
  p_effective_end_date            := l_effective_end_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 11);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_pay_scale_value;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_grade_rule_id          := null;
    p_effective_start_date   := null;
    p_effective_end_date     := null;
    p_object_version_number  := null;
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    -- Added as part of fix to bug 632479
    --
    ROLLBACK TO create_pay_scale_value;
    --
    -- Bugfix 2692195
    -- Reset all OUT/IN OUT parameters
    --
    p_grade_rule_id := null;
    p_object_version_number := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    --
    raise;
    --
    -- End of fix.
    --
end create_pay_scale_value;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_pay_scale_value >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_pay_scale_value
  (p_validate                      in            boolean  default false
  ,p_effective_date                in            date
  ,p_datetrack_update_mode         in            varchar2
  ,p_grade_rule_id                 in            number
  ,p_object_version_number         in out nocopy number
  ,p_currency_code                 in            varchar2
  ,p_maximum                       in            varchar2 default null
  ,p_mid_value                     in            varchar2 default null
  ,p_minimum                       in            varchar2 default null
  ,p_value                         in            varchar2 default null
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_object_version_number      pay_grade_rules_f.object_version_number%TYPE;
  l_object_version_number_temp pay_grade_rules_f.object_version_number%TYPE;
  l_proc                       varchar2(72) := g_package||'update_pay_scale_value';
  l_effective_date             date;
  l_effective_start_date       date;
  l_effective_end_date         date;
  --
begin
  --
  -- Set l_effective_date equal to truncated version of p_effective_date for
  -- API work. Stops dates being passed to row handlers with time portion.
  --
  l_effective_date := trunc(p_effective_date);
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint.
  --
  savepoint update_pay_scale_value;
  --
  hr_utility.set_location(l_proc, 6);
  --
  -- Check that the Grade Rule identified is for a Pay Scale.
  --
  --
  check_rate_type
    (p_grade_rule_id  => p_grade_rule_id
    ,p_effective_date => l_effective_date
    );
  --
  hr_utility.set_location(l_proc, 9);
  --
  --
  l_object_version_number_temp := p_object_version_number;
  l_object_version_number      := p_object_version_number;
  --
  -- Update Grade Rule details.
hr_rate_values_api.update_rate_value(
     p_validate                     => FALSE
    ,p_grade_rule_id                => p_grade_rule_id
    ,p_effective_date               => l_effective_date
    ,p_datetrack_mode               => p_datetrack_update_mode
    ,p_currency_code                => p_currency_code
    ,p_maximum                      => p_maximum
    ,p_mid_value                    => p_mid_value
    ,p_minimum                      => p_minimum
    ,p_value                        => p_value
    ,p_object_version_number        => l_object_version_number
    ,p_effective_start_date         => l_effective_start_date
    ,p_effective_end_date           => l_effective_end_date
    );
  --
  --
  hr_utility.set_location(l_proc, 10);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set out parms
  --
  p_object_version_number         := l_object_version_number;
  p_effective_start_date          := l_effective_start_date;
  p_effective_end_date            := l_effective_end_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 11);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO update_pay_scale_value;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_effective_start_date   := null;
    p_effective_end_date     := null;
    p_object_version_number  := l_object_version_number_temp;
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    -- Added as part of fix to bug 632479
    --
    ROLLBACK TO update_pay_scale_value;
    --
    -- Bugfix 2692195
    -- Reset all OUT/IN OUT parameters
    --
    p_object_version_number := l_object_version_number;
    p_effective_start_date := null;
    p_effective_end_date := null;
    --
    raise;
    --
    -- End of fix.
    --
end update_pay_scale_value;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_pay_scale_value >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_pay_scale_value
  (p_validate                      in            boolean  default false
  ,p_effective_date                in            date
  ,p_datetrack_delete_mode         in            varchar2
  ,p_grade_rule_id                 in            number
  ,p_object_version_number         in out nocopy number
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_object_version_number      pay_grade_rules_f.object_version_number%TYPE;
  l_object_version_number_temp pay_grade_rules_f.object_version_number%TYPE;
  l_proc                       varchar2(72) := g_package||'delete_pay_scale_value';
  l_effective_date             date;
  l_effective_start_date       date;
  l_effective_end_date         date;
  --
begin
  --
  -- Set l_effective_date equal to truncated version of p_effective_date for
  -- API work. Stops dates being passed to row handlers with time portion.
  --
  l_effective_date := trunc(p_effective_date);
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint.
  --
  savepoint delete_pay_scale_value;
  --
  hr_utility.set_location(l_proc, 6);
  --
  -- Check that the Grade Rule identified is for a Pay Scale.
  --
  --
  check_rate_type
    (p_grade_rule_id  => p_grade_rule_id
    ,p_effective_date => l_effective_date
    );
  --
  hr_utility.set_location(l_proc, 9);
  --
  --
  l_object_version_number_temp := p_object_version_number;
  l_object_version_number      := p_object_version_number;
  --
  -- Delete Grade Rule details.
hr_rate_values_api.delete_rate_value(
     p_validate                     => FALSE
    ,p_grade_rule_id                => p_grade_rule_id
    ,p_datetrack_mode               => p_datetrack_delete_mode
    ,p_effective_date               => l_effective_date
    ,p_object_version_number        => l_object_version_number
    ,p_effective_start_date         => l_effective_start_date
    ,p_effective_end_date           => l_effective_end_date
    );
--
  hr_utility.set_location(l_proc, 10);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  p_object_version_number         := l_object_version_number;
  p_effective_start_date          := l_effective_start_date;
  p_effective_end_date            := l_effective_end_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 11);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO delete_pay_scale_value;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_effective_start_date   := null;
    p_effective_end_date     := null;
    p_object_version_number  := l_object_version_number_temp;
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    -- Added as part of fix to bug 632479
    --
    ROLLBACK TO delete_pay_scale_value;
    --
    -- Bugfix 2692195
    -- Reset all OUT/IN OUT parameters
    --
    p_object_version_number := l_object_version_number;
    p_effective_start_date := null;
    p_effective_end_date := null;
    --
    raise;
    --
    -- End of fix.
    --
end delete_pay_scale_value;
--
end hr_pay_scale_value_api;

/
