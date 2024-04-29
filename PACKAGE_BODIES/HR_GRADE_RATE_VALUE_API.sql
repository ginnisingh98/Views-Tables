--------------------------------------------------------
--  DDL for Package Body HR_GRADE_RATE_VALUE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_GRADE_RATE_VALUE_API" as
/* $Header: pygrrapi.pkb 120.0 2005/05/29 05:34:11 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_grade_rate_value_api.';
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
    if l_rate_type <> 'G' then
      --
      hr_utility.set_location(l_proc, 8);
      --
      hr_utility.set_message(801, 'HR_7854_GRR_INV_NOT_G_RATE_TYP');
      hr_utility.raise_error;
      --
    end if;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 11);
end;
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_grade_rate_value >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_grade_rate_value
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_rate_id                       in     number
  ,p_grade_id                      in     number
  ,p_currency_code		   in 	  varchar2 default null
  ,p_maximum                       in     varchar2 default null
  ,p_mid_value                     in     varchar2 default null
  ,p_minimum                       in     varchar2 default null
  ,p_value                         in     varchar2 default null
  ,p_sequence                      in     number   default null
  ,p_grade_rule_id                    out nocopy number
  ,p_object_version_number            out nocopy number
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'create_grade_rate_value';
  l_business_group_id   pay_grade_rules_f.business_group_id%TYPE;
  l_effective_start_date     pay_grade_rules_f.effective_start_date%TYPE;
  l_effective_end_date       pay_grade_rules_f.effective_end_date%TYPE;
  l_sequence            pay_grade_rules_f.sequence%TYPE;
  l_effective_date      date;
  l_grade_rule_id                 number;
  l_object_version_number         pay_grade_rules_f.object_version_number%TYPE;
  --
  cursor csr_get_der_args is
  select rat.business_group_id,
         rat.sequence
    from per_grades rat
   where rat.grade_id = p_grade_id;
  --
begin
  --
  -- Set l_effective_date equal to truncated version of p_effective date for
  -- API work. Stops dates being passed to row handlers with a time portion.
  --
  l_effective_date := trunc(p_effective_date);
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint.
  --
  savepoint create_grade_rate_value;
  hr_utility.set_location(l_proc, 6);
  --
  -- Check that p_grade_id is not null as it is used in the cursor.
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'grade_id',
     p_argument_value => p_grade_id);
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
    hr_utility.set_message(801, 'HR_7311_GRR_INVALID_GRADE');
    hr_utility.raise_error;
  end if;
  --
  close csr_get_der_args;
  --
  hr_utility.set_location(l_proc, 7);
  --
  -- Insert Grade Rule details.
hr_rate_values_api.create_rate_value(
     p_validate                     => FALSE
    ,p_effective_date               => l_effective_date
    ,p_business_group_id            => l_business_group_id
    ,p_rate_id                      => p_rate_id
    ,p_grade_or_spinal_point_id     => p_grade_id
    ,p_rate_type                    => 'G'
    ,p_currency_code		    => p_currency_code
    ,p_maximum                      => p_maximum
    ,p_mid_value                    => p_mid_value
    ,p_minimum                      => p_minimum
    ,p_value                        => p_value
    ,p_sequence                     => p_sequence
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
    ROLLBACK TO create_grade_rate_value;
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
    ROLLBACK TO create_grade_rate_value;
     --
     -- set in out parameters and set out parameters
     --
     p_grade_rule_id          := null;
     p_effective_start_date   := null;
     p_effective_end_date     := null;
     p_object_version_number  := null;
    raise;
    --
    -- End of fix.
    --
end create_grade_rate_value;
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_grade_rate_value >----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_grade_rate_value
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_datetrack_update_mode         in     varchar2
  ,p_grade_rule_id                 in     number
  ,p_currency_code		   in     varchar2 default hr_api.g_varchar2
  ,p_object_version_number         in out nocopy number
  ,p_maximum                       in     varchar2 default hr_api.g_varchar2
  ,p_mid_value                     in     varchar2 default hr_api.g_varchar2
  ,p_minimum                       in     varchar2 default hr_api.g_varchar2
  ,p_value                         in     varchar2 default hr_api.g_varchar2
  ,p_sequence                      in     number   default hr_api.g_number
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_object_version_number      pay_grade_rules_f.object_version_number%TYPE;
  l_object_version_number_temp pay_grade_rules_f.object_version_number%TYPE;
  l_proc                       varchar2(72) := g_package||'update_grade_rate_value';
  l_effective_date             date;
  l_effective_start_date          date;
  l_effective_end_date            date;
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
  savepoint update_grade_rate_value;
  --
  hr_utility.set_location(l_proc, 6);
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
    ,p_currency_code		    => p_currency_code
    ,p_maximum                      => p_maximum
    ,p_mid_value                    => p_mid_value
    ,p_minimum                      => p_minimum
    ,p_value                        => p_value
    ,p_sequence                     => p_sequence
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
  -- Set all output arguments.
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
    ROLLBACK TO update_grade_rate_value;
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
    ROLLBACK TO update_grade_rate_value;
     --
     -- set in out parameters and set out parameters
     --
     p_effective_start_date   := null;
     p_effective_end_date     := null;
     p_object_version_number  := l_object_version_number_temp;

    raise;
    --
    -- End of fix.
    --
end update_grade_rate_value;
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_grade_rate_value >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_grade_rate_value
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_datetrack_delete_mode         in     varchar2
  ,p_grade_rule_id                 in     number
  ,p_object_version_number         in out nocopy number
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_object_version_number      pay_grade_rules_f.object_version_number%TYPE;
  l_object_version_number_temp pay_grade_rules_f.object_version_number%TYPE;
  l_proc                       varchar2(72) := g_package||'delete_grade_rate_value';
  l_effective_date             date;
  l_effective_start_date       date;
  l_effective_end_date         date;
  --
begin
  --
  -- Set l_effective_date to truncated version of p_effective_date for API work
  -- Stops dates being passed to row handlers with time portion.
  --
  l_effective_date := trunc(p_effective_date);
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint.
  --
  savepoint delete_grade_rate_value;
  --
  hr_utility.set_location(l_proc, 6);
  --
  -- Check that the Grade Rule identified is for a Grade Rate.
  --
  check_rate_type
    (p_grade_rule_id  => p_grade_rule_id
    ,p_effective_date => l_effective_date
    );
  --
  --
  l_object_version_number_temp := p_object_version_number;
  l_object_version_number      := p_object_version_number;
  --
  -- Delete Grade Rule details.
  --
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
  hr_utility.set_location(l_proc, 8);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  --
  -- Set out parms.
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
    ROLLBACK TO delete_grade_rate_value;
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
    ROLLBACK TO delete_grade_rate_value;
     --
     -- set in out parameters and set out parameters
     --
     p_effective_start_date   := null;
     p_effective_end_date     := null;
     p_object_version_number  := l_object_version_number_temp;
    raise;
    --
    -- End of fix.
    --
end delete_grade_rate_value;
--
end hr_grade_rate_value_api;

/
