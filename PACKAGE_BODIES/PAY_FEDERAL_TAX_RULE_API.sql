--------------------------------------------------------
--  DDL for Package Body PAY_FEDERAL_TAX_RULE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_FEDERAL_TAX_RULE_API" AS
/* $Header: pyfedapi.pkb 120.0.12000000.3 2007/07/16 02:24:39 ahanda noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  pay_fed_api.';
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_emp_fed_tax_rule_id            in     number
  ,p_object_version_number          in     number
  ,p_effective_date                 in     date
  ,p_datetrack_mode                 in     varchar2
  ,p_validation_start_date          out nocopy   date
  ,p_validation_end_date            out nocopy   date
  ) is
  --
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_federal_tax_rule';
  l_validation_start_date date;
  l_validation_end_date date;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  pay_fed_shd.lck
    (
      p_emp_fed_tax_rule_id        => p_emp_fed_tax_rule_id
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

-- ----------------------------------------------------------------------------
-- |-------------------------< update_fed_tax_rule >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_fed_tax_rule
(
   p_validate                       IN     boolean    default false
  ,p_effective_date                 IN     date
  ,p_datetrack_update_mode          IN     varchar2
  ,p_emp_fed_tax_rule_id            IN     number
  ,p_object_version_number          IN OUT nocopy number
  ,p_sui_state_code                 IN     varchar2  default hr_api.g_varchar2
  ,p_additional_wa_amount           IN     number    default hr_api.g_number
  ,p_filing_status_code             IN     varchar2  default hr_api.g_varchar2
  ,p_fit_override_amount            IN     number    default hr_api.g_number
  ,p_fit_override_rate              IN     number    default hr_api.g_number
  ,p_withholding_allowances         IN     number    default hr_api.g_number
  ,p_cumulative_taxation            IN     varchar2  default hr_api.g_varchar2
  ,p_eic_filing_status_code         IN     varchar2  default hr_api.g_varchar2
  ,p_fit_additional_tax             IN     number    default hr_api.g_number
  ,p_fit_exempt                     IN     varchar2  default hr_api.g_varchar2
  ,p_futa_tax_exempt                IN     varchar2  default hr_api.g_varchar2
  ,p_medicare_tax_exempt            IN     varchar2  default hr_api.g_varchar2
  ,p_ss_tax_exempt                  IN     varchar2  default hr_api.g_varchar2
  ,p_wage_exempt                    IN     varchar2  default hr_api.g_varchar2
  ,p_statutory_employee             IN     varchar2  default hr_api.g_varchar2
  ,p_w2_filed_year                  IN     number    default hr_api.g_number
  ,p_supp_tax_override_rate         IN     number    default hr_api.g_number
  ,p_excessive_wa_reject_date       IN     date      default hr_api.g_date
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
  ,p_fed_information_category       in     varchar2  default hr_api.g_varchar2
  ,p_fed_information1               in     varchar2  default hr_api.g_varchar2
  ,p_fed_information2               in     varchar2  default hr_api.g_varchar2
  ,p_fed_information3               in     varchar2  default hr_api.g_varchar2
  ,p_fed_information4               in     varchar2  default hr_api.g_varchar2
  ,p_fed_information5               in     varchar2  default hr_api.g_varchar2
  ,p_fed_information6               in     varchar2  default hr_api.g_varchar2
  ,p_fed_information7               in     varchar2  default hr_api.g_varchar2
  ,p_fed_information8               in     varchar2  default hr_api.g_varchar2
  ,p_fed_information9               in     varchar2  default hr_api.g_varchar2
  ,p_fed_information10              in     varchar2  default hr_api.g_varchar2
  ,p_fed_information11              in     varchar2  default hr_api.g_varchar2
  ,p_fed_information12              in     varchar2  default hr_api.g_varchar2
  ,p_fed_information13              in     varchar2  default hr_api.g_varchar2
  ,p_fed_information14              in     varchar2  default hr_api.g_varchar2
  ,p_fed_information15              in     varchar2  default hr_api.g_varchar2
  ,p_fed_information16              in     varchar2  default hr_api.g_varchar2
  ,p_fed_information17              in     varchar2  default hr_api.g_varchar2
  ,p_fed_information18              in     varchar2  default hr_api.g_varchar2
  ,p_fed_information19              in     varchar2  default hr_api.g_varchar2
  ,p_fed_information20              in     varchar2  default hr_api.g_varchar2
  ,p_fed_information21              in     varchar2  default hr_api.g_varchar2
  ,p_fed_information22              in     varchar2  default hr_api.g_varchar2
  ,p_fed_information23              in     varchar2  default hr_api.g_varchar2
  ,p_fed_information24              in     varchar2  default hr_api.g_varchar2
  ,p_fed_information25              in     varchar2  default hr_api.g_varchar2
  ,p_fed_information26              in     varchar2  default hr_api.g_varchar2
  ,p_fed_information27              in     varchar2  default hr_api.g_varchar2
  ,p_fed_information28              in     varchar2  default hr_api.g_varchar2
  ,p_fed_information29              in     varchar2  default hr_api.g_varchar2
  ,p_fed_information30              in     varchar2  default hr_api.g_varchar2
  ,p_effective_start_date           OUT nocopy date
  ,p_effective_end_date             OUT nocopy date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_fed_tax_rule';
  l_effective_date          date;
  l_excessive_wa_reject_date date;
  l_object_version_number   pay_us_emp_fed_tax_rules_f.object_version_number%TYPE;
  l_effective_start_date    pay_us_emp_fed_tax_rules_f.effective_start_date%TYPE;
  l_effective_end_date      pay_us_emp_fed_tax_rules_f.effective_end_date%TYPE;
  l_sui_jurisdiction_code   pay_us_emp_fed_tax_rules_f.sui_jurisdiction_code%TYPE;

  -- Bug3433911 -- Local Variables which will hold and the procedure parameter.
  l_fit_exempt varchar2(10)  := p_fit_exempt;
  l_futa_tax_exempt varchar2(10)  := p_futa_tax_exempt;
  l_medicare_tax_exempt varchar2(10) := p_medicare_tax_exempt;
  l_ss_tax_exempt varchar2(10) := p_ss_tax_exempt;
  l_wage_exempt   varchar2(10) := p_wage_exempt;
  --

  --
  cursor c_st_jd is
    select psr.jurisdiction_code
    from   pay_state_rules psr, pay_us_states pus
    where  pus.state_code = p_sui_state_code
    and    pus.state_abbrev = psr.state_code;
  --
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_fed_tax_rule;
  --
  --
  l_effective_date := trunc(p_effective_date);
  l_excessive_wa_reject_date := trunc(p_excessive_wa_reject_date);
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  -- First check if geocode has been installed or not. If no geocodes
  -- installed then return because there is nothing to be done by this
  -- procedure
  --
  -- Changed chk_geocodes_installed to hr_general.chk_maintain_tax_records
  -- to determine if we need to maintain tax records.
  --
  IF  hr_general.chk_maintain_tax_records = 'N' Then
       return;
  end if;
  --
  -- If p_sui_state_code is set to a system value, set the
  -- l_sui_jurisdiction_code as well.  If p_sui_state_code is being
  -- updated, derive l_jurisdiction_code.
  --
  If p_sui_state_code = hr_api.g_varchar2 then
    l_sui_jurisdiction_code := hr_api.g_varchar2;
  Else
    Open c_st_jd;
    Fetch c_st_jd into l_sui_jurisdiction_code;
    If c_st_jd%notfound then
      Close c_st_jd;
      --
      -- The sui_jurisdiction_code for this state code cannot be
      --  found therefore we must error
      --
      hr_utility.set_message(801, 'HR_7952_ADDR_NO_STATE_CODE');
      hr_utility.raise_error;
    End If;
    Close c_st_jd;
  End If;
  --
--  begin
    --
    -- Start of API User Hook for the before hook of update_fed_tax_rule
    --
--    pay_fed_bk2.update_fed_tax_rule_b
--      (
--       p_emp_fed_tax_rule_id            =>  p_emp_fed_tax_rule_id
--      ,p_sui_state_code                 =>  p_sui_state_code
--      ,p_sui_jurisdiction_code          =>  l_sui_jurisdiction_code
--      ,p_additional_wa_amount           =>  p_additional_wa_amount
--      ,p_filing_status_code             =>  p_filing_status_code
--      ,p_fit_override_amount            =>  p_fit_override_amount
--      ,p_fit_override_rate              =>  p_fit_override_rate
--      ,p_withholding_allowances         =>  p_withholding_allowances
--      ,p_cumulative_taxation            =>  p_cumulative_taxation
--      ,p_eic_filing_status_code         =>  p_eic_filing_status_code
--      ,p_fit_additional_tax             =>  p_fit_additional_tax
--      ,p_fit_exempt                     =>  p_fit_exempt
--      ,p_futa_tax_exempt                =>  p_futa_tax_exempt
--      ,p_medicare_tax_exempt            =>  p_medicare_tax_exempt
--      ,p_ss_tax_exempt                  =>  p_ss_tax_exempt
--      ,p_wage_exempt                    =>  p_wage_exempt
--      ,p_statutory_employee             =>  p_statutory_employee
--      ,p_w2_filed_year                  =>  p_w2_filed_year
--      ,p_supp_tax_override_rate         =>  p_supp_tax_override_rate
--      ,p_excessive_wa_reject_date       =>  l_excessive_wa_reject_date
--      ,p_object_version_number          =>  l_object_version_number
--      );
--  exception
--    when hr_api.cannot_find_prog_unit then
--      hr_api.cannot_find_prog_unit_error
--        (p_module_name => 'update_fed_tax_rule'
--        ,p_hook_type   => 'BP'
--        );
    --
    -- End of API User Hook for the before hook of update_fed_tax_rule
    --
--  end;
  --
  --
  pay_fed_upd.upd
    (
     p_emp_fed_tax_rule_id           => p_emp_fed_tax_rule_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_sui_state_code                => p_sui_state_code
    ,p_sui_jurisdiction_code         => l_sui_jurisdiction_code
    ,p_additional_wa_amount          => p_additional_wa_amount
    ,p_filing_status_code            => p_filing_status_code
    ,p_fit_override_amount           => p_fit_override_amount
    ,p_fit_override_rate             => p_fit_override_rate
    ,p_withholding_allowances        => p_withholding_allowances
    ,p_cumulative_taxation           => p_cumulative_taxation
    ,p_eic_filing_status_code        => p_eic_filing_status_code
    ,p_fit_additional_tax            => p_fit_additional_tax
    ,p_fit_exempt                    => l_fit_exempt		 -- Bug3433911
    ,p_futa_tax_exempt               => l_futa_tax_exempt	 -- Bug3433911
    ,p_medicare_tax_exempt           => l_medicare_tax_exempt	 -- Bug3433911
    ,p_ss_tax_exempt                 => l_ss_tax_exempt		 -- Bug3433911
    ,p_wage_exempt                   => l_wage_exempt		 -- Bug3433911
    ,p_statutory_employee            => p_statutory_employee
    ,p_w2_filed_year                 => p_w2_filed_year
    ,p_supp_tax_override_rate        => p_supp_tax_override_rate
    ,p_excessive_wa_reject_date      => l_excessive_wa_reject_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => l_effective_date
    ,p_datetrack_mode                => p_datetrack_update_mode
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
    ,p_fed_information_category            => p_fed_information_category
    ,p_fed_information1                    => p_fed_information1
    ,p_fed_information2                    => p_fed_information2
    ,p_fed_information3                    => p_fed_information3
    ,p_fed_information4                    => p_fed_information4
    ,p_fed_information5                    => p_fed_information5
    ,p_fed_information6                    => p_fed_information6
    ,p_fed_information7                    => p_fed_information7
    ,p_fed_information8                    => p_fed_information8
    ,p_fed_information9                    => p_fed_information9
    ,p_fed_information10                   => p_fed_information10
    ,p_fed_information11                   => p_fed_information11
    ,p_fed_information12                   => p_fed_information12
    ,p_fed_information13                   => p_fed_information13
    ,p_fed_information14                   => p_fed_information14
    ,p_fed_information15                   => p_fed_information15
    ,p_fed_information16                   => p_fed_information16
    ,p_fed_information17                   => p_fed_information17
    ,p_fed_information18                   => p_fed_information18
    ,p_fed_information19                   => p_fed_information19
    ,p_fed_information20                   => p_fed_information20
    ,p_fed_information21                   => p_fed_information21
    ,p_fed_information22                   => p_fed_information22
    ,p_fed_information23                   => p_fed_information23
    ,p_fed_information24                   => p_fed_information24
    ,p_fed_information25                   => p_fed_information25
    ,p_fed_information26                   => p_fed_information26
    ,p_fed_information27                   => p_fed_information27
    ,p_fed_information28                   => p_fed_information28
    ,p_fed_information29                   => p_fed_information29
    ,p_fed_information30                   => p_fed_information30
    );
  --
  --
  pay_us_tax_internal.maintain_wc(
       p_emp_fed_tax_rule_id    =>  p_emp_fed_tax_rule_id
      ,p_effective_start_date   =>  l_effective_start_date
      ,p_effective_end_date     =>  l_effective_end_date
      ,p_effective_date         =>  l_effective_date
      ,p_datetrack_mode         =>  p_datetrack_update_mode
      );
  --
  --
--  begin
    --
    -- Start of API User Hook for the after hook of update_fed_tax_rule
    --
--    pay_fed_bk2.update_fed_tax_rule_a
--      (
--       p_emp_fed_tax_rule_id            =>  p_emp_fed_tax_rule_id
--      ,p_effective_start_date           =>  l_effective_start_date
--      ,p_effective_end_date             =>  l_effective_end_date
--      ,p_sui_state_code                 =>  p_sui_state_code
--      ,p_sui_jurisdiction_code          =>  l_sui_jurisdiction_code
--      ,p_additional_wa_amount           =>  p_additional_wa_amount
--      ,p_filing_status_code             =>  p_filing_status_code
--      ,p_fit_override_amount            =>  p_fit_override_amount
--      ,p_fit_override_rate              =>  p_fit_override_rate
--      ,p_withholding_allowances         =>  p_withholding_allowances
--      ,p_cumulative_taxation            =>  p_cumulative_taxation
--      ,p_eic_filing_status_code         =>  p_eic_filing_status_code
--      ,p_fit_additional_tax             =>  p_fit_additional_tax
--      ,p_fit_exempt                     =>  p_fit_exempt
--      ,p_futa_tax_exempt                =>  p_futa_tax_exempt
--      ,p_medicare_tax_exempt            =>  p_medicare_tax_exempt
--      ,p_ss_tax_exempt                  =>  p_ss_tax_exempt
--      ,p_wage_exempt                    =>  p_wage_exempt
--      ,p_statutory_employee             =>  p_statutory_employee
--      ,p_w2_filed_year                  =>  p_w2_filed_year
--      ,p_supp_tax_override_rate         =>  p_supp_tax_override_rate
--      ,p_excessive_wa_reject_date       =>  l_excessive_wa_reject_date
--      ,p_object_version_number          =>  l_object_version_number
--      );
--  exception
--    when hr_api.cannot_find_prog_unit then
--      hr_api.cannot_find_prog_unit_error
--        (p_module_name => 'update_fed_tax_rule'
--        ,p_hook_type   => 'AP'
--        );
    --
    -- End of API User Hook for the after hook of update_fed_tax_rule
    --
--  end;
  --
  hr_utility.set_location(l_proc, 60);
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
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO update_fed_tax_rule;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_effective_start_date := null;
    p_effective_end_date := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    ROLLBACK TO update_fed_tax_rule;
    raise;
    --
end update_fed_tax_rule;

--
end pay_federal_tax_rule_api;

/
