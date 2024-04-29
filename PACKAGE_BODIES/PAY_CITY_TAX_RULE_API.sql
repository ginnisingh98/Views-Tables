--------------------------------------------------------
--  DDL for Package Body PAY_CITY_TAX_RULE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CITY_TAX_RULE_API" AS
/* $Header: pyctyapi.pkb 120.0.12000000.2 2007/05/01 22:53:30 ahanda noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  pay_cty_api.';
--
-- Global package cursor
--
cursor csr_derive_business_grp(
                               l_assignment_id  number,
                               l_effective_date date
                              )
is
  Select Business_Group_Id
  From Per_Assignments_F
  Where Assignment_Id = l_assignment_id
    and l_effective_date between effective_start_date
      and effective_end_date;

cursor csr_defaulting_date(p_assignment_id number)
is
  Select min(effective_start_date)
  From Pay_Us_Emp_Fed_Tax_Rules_f
  Where assignment_id = p_assignment_id;
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_city_tax_rule >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_city_tax_rule
  (p_validate                       in  boolean   default false
  ,p_emp_city_tax_rule_id           out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_assignment_id                  in  number
  ,p_state_code                     in  varchar2
  ,p_county_code                    in  varchar2
  ,p_city_code                      in  varchar2
  ,p_additional_wa_rate             in  number
  ,p_filing_status_code             in  varchar2
  ,p_lit_additional_tax             in  number
  ,p_lit_override_amount            in  number
  ,p_lit_override_rate              in  number
  ,p_withholding_allowances         in  number
  ,p_lit_exempt                     in  varchar2  default null
  ,p_sd_exempt                      in  varchar2  default null
  ,p_ht_exempt                      in  varchar2  default null
  ,p_wage_exempt                    in  varchar2  default null
  ,p_school_district_code           in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ,p_attribute_category             in     varchar2  default null
  ,p_attribute1                     in     varchar2  default null
  ,p_attribute2                     in     varchar2  default null
  ,p_attribute3                     in     varchar2  default null
  ,p_attribute4                     in     varchar2  default null
  ,p_attribute5                     in     varchar2  default null
  ,p_attribute6                     in     varchar2  default null
  ,p_attribute7                     in     varchar2  default null
  ,p_attribute8                     in     varchar2  default null
  ,p_attribute9                     in     varchar2  default null
  ,p_attribute10                    in     varchar2  default null
  ,p_attribute11                    in     varchar2  default null
  ,p_attribute12                    in     varchar2  default null
  ,p_attribute13                    in     varchar2  default null
  ,p_attribute14                    in     varchar2  default null
  ,p_attribute15                    in     varchar2  default null
  ,p_attribute16                    in     varchar2  default null
  ,p_attribute17                    in     varchar2  default null
  ,p_attribute18                    in     varchar2  default null
  ,p_attribute19                    in     varchar2  default null
  ,p_attribute20                    in     varchar2  default null
  ,p_attribute21                    in     varchar2  default null
  ,p_attribute22                    in     varchar2  default null
  ,p_attribute23                    in     varchar2  default null
  ,p_attribute24                    in     varchar2  default null
  ,p_attribute25                    in     varchar2  default null
  ,p_attribute26                    in     varchar2  default null
  ,p_attribute27                    in     varchar2  default null
  ,p_attribute28                    in     varchar2  default null
  ,p_attribute29                    in     varchar2  default null
  ,p_attribute30                    in     varchar2  default null
  ,p_cty_information_category       in     varchar2  default null
  ,p_cty_information1               in     varchar2  default null
  ,p_cty_information2               in     varchar2  default null
  ,p_cty_information3               in     varchar2  default null
  ,p_cty_information4               in     varchar2  default null
  ,p_cty_information5               in     varchar2  default null
  ,p_cty_information6               in     varchar2  default null
  ,p_cty_information7               in     varchar2  default null
  ,p_cty_information8               in     varchar2  default null
  ,p_cty_information9               in     varchar2  default null
  ,p_cty_information10              in     varchar2  default null
  ,p_cty_information11              in     varchar2  default null
  ,p_cty_information12              in     varchar2  default null
  ,p_cty_information13              in     varchar2  default null
  ,p_cty_information14              in     varchar2  default null
  ,p_cty_information15              in     varchar2  default null
  ,p_cty_information16              in     varchar2  default null
  ,p_cty_information17              in     varchar2  default null
  ,p_cty_information18              in     varchar2  default null
  ,p_cty_information19              in     varchar2  default null
  ,p_cty_information20              in     varchar2  default null
  ,p_cty_information21              in     varchar2  default null
  ,p_cty_information22              in     varchar2  default null
  ,p_cty_information23              in     varchar2  default null
  ,p_cty_information24              in     varchar2  default null
  ,p_cty_information25              in     varchar2  default null
  ,p_cty_information26              in     varchar2  default null
  ,p_cty_information27              in     varchar2  default null
  ,p_cty_information28              in     varchar2  default null
  ,p_cty_information29              in     varchar2  default null
  ,p_cty_information30              in     varchar2  default null
  ) is
  --
  l_jurisdiction_code     pay_us_emp_city_tax_rules.jurisdiction_code%TYPE;
  l_business_group_id     per_assignments_f.business_group_id%TYPE;
  l_defaulting_date       pay_us_emp_city_tax_rules_f.effective_end_date%TYPE;
  l_emp_city_tax_rule_id  pay_us_emp_city_tax_rules_f.emp_city_tax_rule_id%TYPE;
  l_effective_start_date  pay_us_emp_city_tax_rules_f.effective_start_date%TYPE;
  l_effective_end_date    pay_us_emp_city_tax_rules_f.effective_end_date%TYPE;
  l_proc                  varchar2(72) := g_package||'create_city_tax_rule';
  l_object_version_number pay_us_emp_city_tax_rules_f.object_version_number%TYPE;
  l_element_entry_id      pay_element_entries_f.element_entry_id%TYPE := null;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_city_tax_rule;

  --
  hr_utility.set_location(l_proc, 15);
  --
  -- Process Logic
  --
  -- Derive the jurisdiction code
  --
  l_jurisdiction_code := p_state_code||'-'||p_county_code||'-'||p_city_code;
  --
  -- Derive the business group id
  --
  Open csr_derive_business_grp(p_assignment_id, p_effective_date);
  fetch csr_derive_business_grp into l_business_group_id;
  if csr_derive_business_grp%found then
     close csr_derive_business_grp;
  else
     close csr_derive_business_grp;
     hr_utility.set_message(801, 'HR_7348_ASSIGNMENT_INVALID');
     hr_utility.set_message_token('PROCEDURE', l_proc);
     hr_utility.set_message_token('step','20');
     hr_utility.raise_error;
  end if;
  /*
  begin
    --
    --
    -- Start of API User Hook for the before hook of create_city_tax_rule
    --
    pay_cty_bk1.create_city_tax_rule_b
      (
       p_assignment_id                  =>  p_assignment_id
      ,p_state_code                     =>  p_state_code
      ,p_county_code                    =>  p_county_code
      ,p_city_code                      =>  p_city_code
      ,p_business_group_id              =>  l_business_group_id
      ,p_additional_wa_rate             =>  p_additional_wa_rate
      ,p_filing_status_code             =>  p_filing_status_code
      ,p_jurisdiction_code              =>  l_jurisdiction_code
      ,p_lit_additional_tax             =>  p_lit_additional_tax
      ,p_lit_override_amount            =>  p_lit_override_amount
      ,p_lit_override_rate              =>  p_lit_override_rate
      ,p_withholding_allowances         =>  p_withholding_allowances
      ,p_lit_exempt                     =>  p_lit_exempt
      ,p_sd_exempt                      =>  p_sd_exempt
      ,p_ht_exempt                      =>  p_ht_exempt
      ,p_wage_exempt                    =>  p_wage_exempt
      ,p_school_district_code           =>  p_school_district_code
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_CITY_TAX_RULE'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_city_tax_rule
    --
  end;
  */
  --
  -- Business Process Main Code
  --
  open csr_defaulting_date(p_assignment_id);
  fetch csr_defaulting_date into l_defaulting_date;
  if l_defaulting_date is null then
     close csr_defaulting_date;
     hr_utility.set_message(801, 'HR_7182_DT_NO_MIN_MAX_ROWS');
     hr_utility.set_message_token('table_name', 'pay_us_emp_fed_tax_rules_f');
     hr_utility.set_message_token('step','25');
     hr_utility.raise_error;
  else
     close csr_defaulting_date;
     pay_cty_ins.ins
       (
        p_emp_city_tax_rule_id          => l_emp_city_tax_rule_id
       ,p_effective_start_date          => l_effective_start_date
       ,p_effective_end_date            => l_effective_end_date
       ,p_assignment_id                 => p_assignment_id
       ,p_state_code                    => p_state_code
       ,p_county_code                   => p_county_code
       ,p_city_code                     => p_city_code
       ,p_business_group_id             => l_business_group_id
       ,p_additional_wa_rate            => p_additional_wa_rate
       ,p_filing_status_code            => p_filing_status_code
       ,p_jurisdiction_code             => l_jurisdiction_code
       ,p_lit_additional_tax            => p_lit_additional_tax
       ,p_lit_override_amount           => p_lit_override_amount
       ,p_lit_override_rate             => p_lit_override_rate
       ,p_withholding_allowances        => p_withholding_allowances
       ,p_lit_exempt                    => p_lit_exempt
       ,p_sd_exempt                     => p_sd_exempt
       ,p_ht_exempt                     => p_ht_exempt
       ,p_wage_exempt                   => p_wage_exempt
       ,p_school_district_code          => p_school_district_code
       ,p_object_version_number         => l_object_version_number
       ,p_effective_date                => l_defaulting_date
    ,p_attribute_category            => p_attribute_category
    ,p_attribute1                    => p_attribute1
    ,p_attribute2                    => p_attribute2
    ,p_attribute3                    => p_attribute3
    ,p_attribute4                    => p_attribute4
    ,p_attribute5                    => p_attribute5
    ,p_attribute6                    => p_attribute6
    ,p_attribute7                    => p_attribute7
    ,p_attribute8                    => p_attribute8
    ,p_attribute9                    => p_attribute9
    ,p_attribute10                   => p_attribute10
    ,p_attribute11                   => p_attribute11
    ,p_attribute12                   => p_attribute12
    ,p_attribute13                   => p_attribute13
    ,p_attribute14                   => p_attribute14
    ,p_attribute15                   => p_attribute15
    ,p_attribute16                   => p_attribute16
    ,p_attribute17                   => p_attribute17
    ,p_attribute18                   => p_attribute18
    ,p_attribute19                   => p_attribute19
    ,p_attribute20                   => p_attribute20
    ,p_attribute21                   => p_attribute21
    ,p_attribute22                   => p_attribute22
    ,p_attribute23                   => p_attribute23
    ,p_attribute24                   => p_attribute24
    ,p_attribute25                   => p_attribute25
    ,p_attribute26                   => p_attribute26
    ,p_attribute27                   => p_attribute27
    ,p_attribute28                   => p_attribute28
    ,p_attribute29                   => p_attribute29
    ,p_attribute30                   => p_attribute30
    ,p_cty_information_category      => p_cty_information_category
    ,p_cty_information1                    => p_cty_information1
    ,p_cty_information2                    => p_cty_information2
    ,p_cty_information3                    => p_cty_information3
    ,p_cty_information4                    => p_cty_information4
    ,p_cty_information5                    => p_cty_information5
    ,p_cty_information6                    => p_cty_information6
    ,p_cty_information7                    => p_cty_information7
    ,p_cty_information8                    => p_cty_information8
    ,p_cty_information9                    => p_cty_information9
    ,p_cty_information10                   => p_cty_information10
    ,p_cty_information11                   => p_cty_information11
    ,p_cty_information12                   => p_cty_information12
    ,p_cty_information13                   => p_cty_information13
    ,p_cty_information14                   => p_cty_information14
    ,p_cty_information15                   => p_cty_information15
    ,p_cty_information16                   => p_cty_information16
    ,p_cty_information17                   => p_cty_information17
    ,p_cty_information18                   => p_cty_information18
    ,p_cty_information19                   => p_cty_information19
    ,p_cty_information20                   => p_cty_information20
    ,p_cty_information21                   => p_cty_information21
    ,p_cty_information22                   => p_cty_information22
    ,p_cty_information23                   => p_cty_information23
    ,p_cty_information24                   => p_cty_information24
    ,p_cty_information25                   => p_cty_information25
    ,p_cty_information26                   => p_cty_information26
    ,p_cty_information27                   => p_cty_information27
    ,p_cty_information28                   => p_cty_information28
    ,p_cty_information29                   => p_cty_information29
    ,p_cty_information30                   => p_cty_information30
       );
     --
     hr_utility.set_location(l_proc, 30);
     --
     pay_us_tax_internal.maintain_tax_percentage
        (
         p_assignment_id          => p_assignment_id,
         p_effective_date         => p_effective_date,
         p_state_code             => p_state_code,
         p_county_code            => p_county_code,
         p_city_code              => p_city_code,
         p_datetrack_mode         => 'INSERT',
         p_calculate_pct          => FALSE,
         p_effective_start_date   => l_effective_start_date,
         p_effective_end_date     => l_effective_end_date
        );
    --
    -- Call create_asg_geo_row to create rows in the pay_us_asg_reporting
    -- table if this is a new city
    --
    pay_asg_geo_pkg.create_asg_geo_row(
                 p_assignment_id => p_assignment_id
                ,p_jurisdiction  => l_jurisdiction_code
                );
  End if;
  --
  /*
  begin
    --
    -- Start of API User Hook for the after hook of create_city_tax_rule
    --
    pay_cty_bk1.create_city_tax_rule_a
      (
       p_emp_city_tax_rule_id           =>  l_emp_city_tax_rule_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_assignment_id                  =>  p_assignment_id
      ,p_state_code                     =>  p_state_code
      ,p_county_code                    =>  p_county_code
      ,p_city_code                      =>  p_city_code
      ,p_business_group_id              =>  l_business_group_id
      ,p_additional_wa_rate             =>  p_additional_wa_rate
      ,p_filing_status_code             =>  p_filing_status_code
      ,p_jurisdiction_code              =>  l_jurisdiction_code
      ,p_lit_additional_tax             =>  p_lit_additional_tax
      ,p_lit_override_amount            =>  p_lit_override_amount
      ,p_lit_override_rate              =>  p_lit_override_rate
      ,p_withholding_allowances         =>  p_withholding_allowances
      ,p_lit_exempt                     =>  p_lit_exempt
      ,p_sd_exempt                      =>  p_sd_exempt
      ,p_ht_exempt                      =>  p_ht_exempt
      ,p_wage_exempt                    =>  p_wage_exempt
      ,p_school_district_code           =>  p_school_district_code
      ,p_object_version_number          =>  l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_CITY_TAX_RULE'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_city_tax_rule
    --
  end;
  */
  --
  hr_utility.set_location(l_proc, 35);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_emp_city_tax_rule_id := l_emp_city_tax_rule_id;
  p_effective_start_date := l_effective_start_date;
  p_effective_end_date := l_effective_end_date;
  p_object_version_number := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 40);
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_city_tax_rule;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_emp_city_tax_rule_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 60);
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    ROLLBACK TO create_city_tax_rule;
    p_emp_city_tax_rule_id   := null;
    p_effective_start_date   := null;
    p_effective_end_date     := null;
    p_object_version_number  := null;

    raise;
    --
end create_city_tax_rule;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_city_tax_rule >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_city_tax_rule
  (p_validate                       in  boolean   default false
  ,p_emp_city_tax_rule_id           in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_additional_wa_rate             in  number    default hr_api.g_number
  ,p_filing_status_code             in  varchar2  default hr_api.g_varchar2
  ,p_lit_additional_tax             in  number    default hr_api.g_number
  ,p_lit_override_amount            in  number    default hr_api.g_number
  ,p_lit_override_rate              in  number    default hr_api.g_number
  ,p_withholding_allowances         in  number    default hr_api.g_number
  ,p_lit_exempt                     in  varchar2  default hr_api.g_varchar2
  ,p_sd_exempt                      in  varchar2  default hr_api.g_varchar2
  ,p_ht_exempt                      in  varchar2  default hr_api.g_varchar2
  ,p_wage_exempt                    in  varchar2  default hr_api.g_varchar2
  ,p_school_district_code           in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ,p_attribute_category             in     varchar2  default hr_api.g_varchar2
  ,p_attribute1                     in     varchar2  default hr_api.g_varchar2
  ,p_attribute2                     in     varchar2  default hr_api.g_varchar2
  ,p_attribute3                     in     varchar2  default hr_api.g_varchar2
  ,p_attribute4                     in     varchar2  default hr_api.g_varchar2
  ,p_attribute5                     in     varchar2  default hr_api.g_varchar2
  ,p_attribute6                     in     varchar2  default hr_api.g_varchar2
  ,p_attribute7                     in     varchar2  default hr_api.g_varchar2
  ,p_attribute8                     in     varchar2  default hr_api.g_varchar2
  ,p_attribute9                     in     varchar2  default hr_api.g_varchar2
  ,p_attribute10                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute11                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute12                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute13                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute14                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute15                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute16                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute17                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute18                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute19                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute20                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute21                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute22                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute23                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute24                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute25                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute26                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute27                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute28                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute29                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute30                    in     varchar2  default hr_api.g_varchar2
  ,p_cty_information_category       in     varchar2  default hr_api.g_varchar2
  ,p_cty_information1               in     varchar2  default hr_api.g_varchar2
  ,p_cty_information2               in     varchar2  default hr_api.g_varchar2
  ,p_cty_information3               in     varchar2  default hr_api.g_varchar2
  ,p_cty_information4               in     varchar2  default hr_api.g_varchar2
  ,p_cty_information5               in     varchar2  default hr_api.g_varchar2
  ,p_cty_information6               in     varchar2  default hr_api.g_varchar2
  ,p_cty_information7               in     varchar2  default hr_api.g_varchar2
  ,p_cty_information8               in     varchar2  default hr_api.g_varchar2
  ,p_cty_information9               in     varchar2  default hr_api.g_varchar2
  ,p_cty_information10              in     varchar2  default hr_api.g_varchar2
  ,p_cty_information11              in     varchar2  default hr_api.g_varchar2
  ,p_cty_information12              in     varchar2  default hr_api.g_varchar2
  ,p_cty_information13              in     varchar2  default hr_api.g_varchar2
  ,p_cty_information14              in     varchar2  default hr_api.g_varchar2
  ,p_cty_information15              in     varchar2  default hr_api.g_varchar2
  ,p_cty_information16              in     varchar2  default hr_api.g_varchar2
  ,p_cty_information17              in     varchar2  default hr_api.g_varchar2
  ,p_cty_information18              in     varchar2  default hr_api.g_varchar2
  ,p_cty_information19              in     varchar2  default hr_api.g_varchar2
  ,p_cty_information20              in     varchar2  default hr_api.g_varchar2
  ,p_cty_information21              in     varchar2  default hr_api.g_varchar2
  ,p_cty_information22              in     varchar2  default hr_api.g_varchar2
  ,p_cty_information23              in     varchar2  default hr_api.g_varchar2
  ,p_cty_information24              in     varchar2  default hr_api.g_varchar2
  ,p_cty_information25              in     varchar2  default hr_api.g_varchar2
  ,p_cty_information26              in     varchar2  default hr_api.g_varchar2
  ,p_cty_information27              in     varchar2  default hr_api.g_varchar2
  ,p_cty_information28              in     varchar2  default hr_api.g_varchar2
  ,p_cty_information29              in     varchar2  default hr_api.g_varchar2
  ,p_cty_information30              in     varchar2  default hr_api.g_varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'update_city_tax_rule';
  l_object_version_number pay_us_emp_city_tax_rules_f.object_version_number%TYPE;
  l_effective_start_date  pay_us_emp_city_tax_rules_f.effective_start_date%TYPE;
  l_effective_end_date    pay_us_emp_city_tax_rules_f.effective_end_date%TYPE;
  l_assignment_id         pay_us_emp_city_tax_rules_f.assignment_id%TYPE;
  l_jurisdiction_code     pay_us_emp_city_tax_rules_f.jurisdiction_code%TYPE;
  --
  CURSOR csr_assignment_id (p_rule_id NUMBER,
                            p_eff_date DATE) IS
    SELECT ctr.assignment_id,
           ctr.state_code||'-'||ctr.school_district_code
    FROM   pay_us_emp_city_tax_rules_f ctr
    WHERE  ctr.emp_city_tax_rule_id = p_rule_id
    AND    p_eff_date BETWEEN ctr.effective_start_date
                          AND ctr.effective_end_date;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_city_tax_rule;
  --
  hr_utility.set_location(l_proc, 15);
  --
  -- Process Logic
  --
  -- Changed call to check hr_general.chk_maintain_tax_records to
  -- determine if we need to maintain tax records.
  --
   IF  hr_general.chk_maintain_tax_records = 'N' Then
     return;
  end if;
  --
  l_object_version_number := p_object_version_number;
  --
  /*
  begin
    --
    -- Start of API User Hook for the before hook of update_city_tax_rule
    --
    pay_cty_bk2.update_city_tax_rule_b
      (
       p_emp_city_tax_rule_id           =>  p_emp_city_tax_rule_id
      ,p_assignment_id                  =>  p_assignment_id
      ,p_state_code                     =>  p_state_code
      ,p_county_code                    =>  p_county_code
      ,p_city_code                      =>  p_city_code
      ,p_business_group_id              =>  l_business_group_id
      ,p_additional_wa_rate             =>  p_additional_wa_rate
      ,p_filing_status_code             =>  p_filing_status_code
      ,p_jurisdiction_code              =>  l_jurisdiction_code
      ,p_lit_additional_tax             =>  p_lit_additional_tax
      ,p_lit_override_amount            =>  p_lit_override_amount
      ,p_lit_override_rate              =>  p_lit_override_rate
      ,p_withholding_allowances         =>  p_withholding_allowances
      ,p_lit_exempt                     =>  p_lit_exempt
      ,p_sd_exempt                      =>  p_sd_exempt
      ,p_ht_exempt                      =>  p_ht_exempt
      ,p_wage_exempt                    =>  p_wage_exempt
      ,p_school_district_code           =>  p_school_district_code
      ,p_object_version_number          =>  p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_CITY_TAX_RULE'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_city_tax_rule
    --
  end;
  */
  --
  pay_cty_upd.upd
     (
      p_emp_city_tax_rule_id          => p_emp_city_tax_rule_id
     ,p_effective_start_date          => l_effective_start_date
     ,p_effective_end_date            => l_effective_end_date
     ,p_additional_wa_rate            => p_additional_wa_rate
     ,p_filing_status_code            => p_filing_status_code
     ,p_lit_additional_tax            => p_lit_additional_tax
     ,p_lit_override_amount           => p_lit_override_amount
     ,p_lit_override_rate             => p_lit_override_rate
     ,p_withholding_allowances        => p_withholding_allowances
     ,p_lit_exempt                    => p_lit_exempt
     ,p_sd_exempt                     => p_sd_exempt
     ,p_ht_exempt                     => p_ht_exempt
     ,p_wage_exempt                   => p_wage_exempt
     ,p_school_district_code          => p_school_district_code
     ,p_object_version_number         => l_object_version_number
     ,p_effective_date                => p_effective_date
     ,p_datetrack_mode                => p_datetrack_mode
    ,p_attribute_category            => p_attribute_category
    ,p_attribute1                    => p_attribute1
    ,p_attribute2                    => p_attribute2
    ,p_attribute3                    => p_attribute3
    ,p_attribute4                    => p_attribute4
    ,p_attribute5                    => p_attribute5
    ,p_attribute6                    => p_attribute6
    ,p_attribute7                    => p_attribute7
    ,p_attribute8                    => p_attribute8
    ,p_attribute9                    => p_attribute9
    ,p_attribute10                   => p_attribute10
    ,p_attribute11                   => p_attribute11
    ,p_attribute12                   => p_attribute12
    ,p_attribute13                   => p_attribute13
    ,p_attribute14                   => p_attribute14
    ,p_attribute15                   => p_attribute15
    ,p_attribute16                   => p_attribute16
    ,p_attribute17                   => p_attribute17
    ,p_attribute18                   => p_attribute18
    ,p_attribute19                   => p_attribute19
    ,p_attribute20                   => p_attribute20
    ,p_attribute21                   => p_attribute21
    ,p_attribute22                   => p_attribute22
    ,p_attribute23                   => p_attribute23
    ,p_attribute24                   => p_attribute24
    ,p_attribute25                   => p_attribute25
    ,p_attribute26                   => p_attribute26
    ,p_attribute27                   => p_attribute27
    ,p_attribute28                   => p_attribute28
    ,p_attribute29                   => p_attribute29
    ,p_attribute30                   => p_attribute30
    ,p_cty_information_category      => p_cty_information_category
    ,p_cty_information1                    => p_cty_information1
    ,p_cty_information2                    => p_cty_information2
    ,p_cty_information3                    => p_cty_information3
    ,p_cty_information4                    => p_cty_information4
    ,p_cty_information5                    => p_cty_information5
    ,p_cty_information6                    => p_cty_information6
    ,p_cty_information7                    => p_cty_information7
    ,p_cty_information8                    => p_cty_information8
    ,p_cty_information9                    => p_cty_information9
    ,p_cty_information10                   => p_cty_information10
    ,p_cty_information11                   => p_cty_information11
    ,p_cty_information12                   => p_cty_information12
    ,p_cty_information13                   => p_cty_information13
    ,p_cty_information14                   => p_cty_information14
    ,p_cty_information15                   => p_cty_information15
    ,p_cty_information16                   => p_cty_information16
    ,p_cty_information17                   => p_cty_information17
    ,p_cty_information18                   => p_cty_information18
    ,p_cty_information19                   => p_cty_information19
    ,p_cty_information20                   => p_cty_information20
    ,p_cty_information21                   => p_cty_information21
    ,p_cty_information22                   => p_cty_information22
    ,p_cty_information23                   => p_cty_information23
    ,p_cty_information24                   => p_cty_information24
    ,p_cty_information25                   => p_cty_information25
    ,p_cty_information26                   => p_cty_information26
    ,p_cty_information27                   => p_cty_information27
    ,p_cty_information28                   => p_cty_information28
    ,p_cty_information29                   => p_cty_information29
    ,p_cty_information30                   => p_cty_information30
     );
  --
  -- Call create_asg_geo_row to create rows in the pay_us_asg_reporting
  -- table if this city school district has changed.
  --
  if p_school_district_code IS NOT NULL AND
     p_school_district_code <> hr_api.g_varchar2 THEN
    hr_utility.set_location(l_proc, 22);
    OPEN csr_assignment_id(p_emp_city_tax_rule_id,
                           p_effective_date);
    FETCH csr_assignment_id
    INTO l_assignment_id,
         l_jurisdiction_code;
    pay_asg_geo_pkg.create_asg_geo_row(
               p_assignment_id => l_assignment_id
              ,p_jurisdiction  => l_jurisdiction_code
              );
    CLOSE csr_assignment_id;
  end if;
  --
  /*
  begin
    --
    -- Start of API User Hook for the after hook of update_city_tax_rule
    --
    pay_cty_bk2.update_city_tax_rule_a
      (
       p_emp_city_tax_rule_id           =>  p_emp_city_tax_rule_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_assignment_id                  =>  p_assignment_id
      ,p_state_code                     =>  p_state_code
      ,p_county_code                    =>  p_county_code
      ,p_city_code                      =>  p_city_code
      ,p_business_group_id              =>  l_business_group_id
      ,p_additional_wa_rate             =>  p_additional_wa_rate
      ,p_filing_status_code             =>  p_filing_status_code
      ,p_jurisdiction_code              =>  p_jurisdiction_code
      ,p_lit_additional_tax             =>  p_lit_additional_tax
      ,p_lit_override_amount            =>  p_lit_override_amount
      ,p_lit_override_rate              =>  p_lit_override_rate
      ,p_withholding_allowances         =>  p_withholding_allowances
      ,p_lit_exempt                     =>  p_lit_exempt
      ,p_sd_exempt                      =>  p_sd_exempt
      ,p_ht_exempt                      =>  p_ht_exempt
      ,p_wage_exempt                    =>  p_wage_exempt
      ,p_school_district_code           =>  p_school_district_code
      ,p_object_version_number          =>  p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_CITY_TAX_RULE'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_city_tax_rule
    --
  end;
  */
  --
  hr_utility.set_location(l_proc, 25);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_object_version_number := l_object_version_number;
  p_effective_start_date := l_effective_start_date;
  p_effective_end_date := l_effective_end_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 30);
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO update_city_tax_rule;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := l_object_version_number;
    p_effective_start_date := null;
    p_effective_end_date := null;
    hr_utility.set_location(' Leaving:'||l_proc, 50);
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    ROLLBACK TO update_city_tax_rule;
    p_effective_start_date   := null;
    p_effective_end_date     := null;
    p_object_version_number  := l_object_version_number;

    raise;
    --
end update_city_tax_rule;
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_emp_city_tax_rule_id           in     number
  ,p_object_version_number          in     number
  ,p_effective_date                 in     date
  ,p_datetrack_mode                 in     varchar2
  ,p_validation_start_date          out nocopy    date
  ,p_validation_end_date            out nocopy    date
  ) is
  --
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_city_tax_rule';
  l_validation_start_date date;
  l_validation_end_date date;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  pay_cty_shd.lck
    (
      p_emp_city_tax_rule_id       => p_emp_city_tax_rule_id
     ,p_validation_start_date      => l_validation_start_date
     ,p_validation_end_date        => l_validation_end_date
     ,p_object_version_number      => p_object_version_number
     ,p_effective_date             => p_effective_date
     ,p_datetrack_mode             => p_datetrack_mode
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end pay_city_tax_rule_api;

/
