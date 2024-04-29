--------------------------------------------------------
--  DDL for Package Body PAY_STATE_TAX_RULE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_STATE_TAX_RULE_API" AS
/* $Header: pystaapi.pkb 120.6.12010000.1 2008/07/27 23:43:14 appldev ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  pay_sta_api.';
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_emp_state_tax_rule_id          in     	number
  ,p_object_version_number          in     	number
  ,p_effective_date                 in     	date
  ,p_datetrack_mode                 in     	varchar2
  ,p_validation_start_date          out nocopy  date
  ,p_validation_end_date            out nocopy  date
  ) is
  --
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'lck';
  l_validation_start_date date;
  l_validation_end_date date;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  pay_sta_shd.lck
    (
      p_emp_state_tax_rule_id      => p_emp_state_tax_rule_id
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
-- |------------------------< create_state_tax_rule >------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_state_tax_rule
(
   p_validate                       IN      boolean   default false
  ,p_effective_date                 IN      date
  ,p_default_flag                   IN      varchar2  default null
  ,p_assignment_id                  IN      number
  ,p_state_code                     IN      varchar2
  ,p_additional_wa_amount           IN      number    default null
  ,p_filing_status_code             IN      varchar2  default null
  ,p_remainder_percent              IN      number    default null
  ,p_secondary_wa                   IN      number    default null
  ,p_sit_additional_tax             IN      number    default null
  ,p_sit_override_amount            IN      number    default null
  ,p_sit_override_rate              IN      number    default null
  ,p_withholding_allowances         IN      number    default null
  ,p_excessive_wa_reject_date       IN      date      default null
  ,p_sdi_exempt                     IN      varchar2  default null
  ,p_sit_exempt                     IN      varchar2  default null
  ,p_sit_optional_calc_ind          IN      varchar2  default null
  ,p_state_non_resident_cert        IN      varchar2  default null
  ,p_sui_exempt                     IN      varchar2  default null
  ,p_wc_exempt                      IN      varchar2  default null
  ,p_wage_exempt                    IN      varchar2  default null
  ,p_sui_wage_base_override_amoun   IN      number    default null
  ,p_supp_tax_override_rate         IN      number    default null
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
  ,p_sta_information_category       in     varchar2  default null
  ,p_sta_information1               in     varchar2  default null
  ,p_sta_information2               in     varchar2  default null
  ,p_sta_information3               in     varchar2  default null
  ,p_sta_information4               in     varchar2  default null
  ,p_sta_information5               in     varchar2  default null
  ,p_sta_information6               in     varchar2  default null
  ,p_sta_information7               in     varchar2  default null
  ,p_sta_information8               in     varchar2  default null
  ,p_sta_information9               in     varchar2  default null
  ,p_sta_information10              in     varchar2  default null
  ,p_sta_information11              in     varchar2  default null
  ,p_sta_information12              in     varchar2  default null
  ,p_sta_information13              in     varchar2  default null
  ,p_sta_information14              in     varchar2  default null
  ,p_sta_information15              in     varchar2  default null
  ,p_sta_information16              in     varchar2  default null
  ,p_sta_information17              in     varchar2  default null
  ,p_sta_information18              in     varchar2  default null
  ,p_sta_information19              in     varchar2  default null
  ,p_sta_information20              in     varchar2  default null
  ,p_sta_information21              in     varchar2  default null
  ,p_sta_information22              in     varchar2  default null
  ,p_sta_information23              in     varchar2  default null
  ,p_sta_information24              in     varchar2  default null
  ,p_sta_information25              in     varchar2  default null
  ,p_sta_information26              in     varchar2  default null
  ,p_sta_information27              in     varchar2  default null
  ,p_sta_information28              in     varchar2  default null
  ,p_sta_information29              in     varchar2  default null
  ,p_sta_information30              in     varchar2  default null
  ,p_emp_state_tax_rule_id             OUT  nocopy number
  ,p_object_version_number             OUT  nocopy number
  ,p_effective_start_date              OUT  nocopy date
  ,p_effective_end_date                OUT  nocopy date
 ) is
  --
  -- Declare cursors and local variables
  --
  l_emp_state_tax_rule_id            pay_us_emp_state_tax_rules_f.emp_state_tax_rule_id%TYPE;
  l_object_version_number            pay_us_emp_state_tax_rules_f.object_version_number%TYPE;
  l_jurisdiction_code                pay_us_emp_state_tax_rules_f.jurisdiction_code%TYPE;
  l_business_group_id                pay_us_emp_state_tax_rules_f.business_group_id%TYPE;
  l_additional_wa_amount             pay_us_emp_state_tax_rules_f.additional_wa_amount%TYPE;
  l_filing_status_code               pay_us_emp_state_tax_rules_f.filing_status_code%TYPE;
  l_remainder_percent                pay_us_emp_state_tax_rules_f.remainder_percent%TYPE;
  l_secondary_wa                     pay_us_emp_state_tax_rules_f.secondary_wa%TYPE;
  l_sit_additional_tax               pay_us_emp_state_tax_rules_f.sit_additional_tax%TYPE;
  l_sit_override_amount              pay_us_emp_state_tax_rules_f.sit_override_amount%TYPE;
  l_sit_override_rate                pay_us_emp_state_tax_rules_f.sit_override_rate%TYPE;
  l_withholding_allowances           pay_us_emp_state_tax_rules_f.withholding_allowances%TYPE;
  l_excessive_wa_reject_date         pay_us_emp_state_tax_rules_f.excessive_wa_reject_date%TYPE;
  l_sdi_exempt                       pay_us_emp_state_tax_rules_f.sdi_exempt%TYPE;
  l_sit_exempt                       pay_us_emp_state_tax_rules_f.sit_exempt%TYPE;
  l_sit_optional_calc_ind            pay_us_emp_state_tax_rules_f.sit_optional_calc_ind%TYPE;
  l_state_non_resident_cert          pay_us_emp_state_tax_rules_f.state_non_resident_cert%TYPE;
  l_sui_exempt                       pay_us_emp_state_tax_rules_f.sui_exempt%TYPE;
  l_wc_exempt                        pay_us_emp_state_tax_rules_f.wc_exempt%TYPE;
  l_wage_exempt                      pay_us_emp_state_tax_rules_f.wage_exempt%TYPE;
  l_sui_wage_base_override_amoun     pay_us_emp_state_tax_rules_f.sui_wage_base_override_amount%TYPE;
  l_supp_tax_override_rate           pay_us_emp_state_tax_rules_f.supp_tax_override_rate%TYPE;
  l_effective_start_date             pay_us_emp_state_tax_rules_f.effective_start_date%TYPE;
  l_effective_end_date               pay_us_emp_state_tax_rules_f.effective_end_date%TYPE;
  l_attribute_category               pay_us_emp_state_tax_rules_f.attribute_category%TYPE;
  l_attribute1                       pay_us_emp_state_tax_rules_f.attribute1%TYPE;
  l_attribute2                       pay_us_emp_state_tax_rules_f.attribute2%TYPE;
  l_attribute3                       pay_us_emp_state_tax_rules_f.attribute3%TYPE;
  l_attribute4                       pay_us_emp_state_tax_rules_f.attribute4%TYPE;
  l_attribute5                       pay_us_emp_state_tax_rules_f.attribute5%TYPE;
  l_attribute6                       pay_us_emp_state_tax_rules_f.attribute6%TYPE;
  l_attribute7                       pay_us_emp_state_tax_rules_f.attribute7%TYPE;
  l_attribute8                       pay_us_emp_state_tax_rules_f.attribute8%TYPE;
  l_attribute9                       pay_us_emp_state_tax_rules_f.attribute9%TYPE;
  l_attribute10                      pay_us_emp_state_tax_rules_f.attribute10%TYPE;
  l_attribute11                      pay_us_emp_state_tax_rules_f.attribute11%TYPE;
  l_attribute12                      pay_us_emp_state_tax_rules_f.attribute12%TYPE;
  l_attribute13                      pay_us_emp_state_tax_rules_f.attribute13%TYPE;
  l_attribute14                      pay_us_emp_state_tax_rules_f.attribute14%TYPE;
  l_attribute15                      pay_us_emp_state_tax_rules_f.attribute15%TYPE;
  l_attribute16                      pay_us_emp_state_tax_rules_f.attribute16%TYPE;
  l_attribute17                      pay_us_emp_state_tax_rules_f.attribute17%TYPE;
  l_attribute18                      pay_us_emp_state_tax_rules_f.attribute18%TYPE;
  l_attribute19                      pay_us_emp_state_tax_rules_f.attribute19%TYPE;
  l_attribute20                      pay_us_emp_state_tax_rules_f.attribute20%TYPE;
  l_attribute21                      pay_us_emp_state_tax_rules_f.attribute21%TYPE;
  l_attribute22                      pay_us_emp_state_tax_rules_f.attribute22%TYPE;
  l_attribute23                      pay_us_emp_state_tax_rules_f.attribute23%TYPE;
  l_attribute24                      pay_us_emp_state_tax_rules_f.attribute24%TYPE;
  l_attribute25                      pay_us_emp_state_tax_rules_f.attribute25%TYPE;
  l_attribute26                      pay_us_emp_state_tax_rules_f.attribute26%TYPE;
  l_attribute27                      pay_us_emp_state_tax_rules_f.attribute27%TYPE;
  l_attribute28                      pay_us_emp_state_tax_rules_f.attribute28%TYPE;
  l_attribute29                      pay_us_emp_state_tax_rules_f.attribute29%TYPE;
  l_attribute30                      pay_us_emp_state_tax_rules_f.attribute30%TYPE;
  l_sta_information_category         pay_us_emp_state_tax_rules_f.sta_information_category%TYPE;
  l_sta_information1                 pay_us_emp_state_tax_rules_f.sta_information1%TYPE;
  l_sta_information2                 pay_us_emp_state_tax_rules_f.sta_information2%TYPE;
  l_sta_information3                 pay_us_emp_state_tax_rules_f.sta_information3%TYPE;
  l_sta_information4                 pay_us_emp_state_tax_rules_f.sta_information4%TYPE;
  l_sta_information5                 pay_us_emp_state_tax_rules_f.sta_information5%TYPE;
  l_sta_information6                 pay_us_emp_state_tax_rules_f.sta_information6%TYPE;
  l_sta_information7                 pay_us_emp_state_tax_rules_f.sta_information7%TYPE;
  l_sta_information8                 pay_us_emp_state_tax_rules_f.sta_information8%TYPE;
  l_sta_information9                 pay_us_emp_state_tax_rules_f.sta_information9%TYPE;
  l_sta_information10                pay_us_emp_state_tax_rules_f.sta_information10%TYPE;
  l_sta_information11                pay_us_emp_state_tax_rules_f.sta_information11%TYPE;
  l_sta_information12                pay_us_emp_state_tax_rules_f.sta_information12%TYPE;
  l_sta_information13                pay_us_emp_state_tax_rules_f.sta_information13%TYPE;
  l_sta_information14                pay_us_emp_state_tax_rules_f.sta_information14%TYPE;
  l_sta_information15                pay_us_emp_state_tax_rules_f.sta_information15%TYPE;
  l_sta_information16                pay_us_emp_state_tax_rules_f.sta_information16%TYPE;
  l_sta_information17                pay_us_emp_state_tax_rules_f.sta_information17%TYPE;
  l_sta_information18                pay_us_emp_state_tax_rules_f.sta_information18%TYPE;
  l_sta_information19                pay_us_emp_state_tax_rules_f.sta_information19%TYPE;
  l_sta_information20                pay_us_emp_state_tax_rules_f.sta_information20%TYPE;
  l_sta_information21                pay_us_emp_state_tax_rules_f.sta_information21%TYPE;
  l_sta_information22                pay_us_emp_state_tax_rules_f.sta_information22%TYPE;
  l_sta_information23                pay_us_emp_state_tax_rules_f.sta_information23%TYPE;
  l_sta_information24                pay_us_emp_state_tax_rules_f.sta_information24%TYPE;
  l_sta_information25                pay_us_emp_state_tax_rules_f.sta_information25%TYPE;
  l_sta_information26                pay_us_emp_state_tax_rules_f.sta_information26%TYPE;
  l_sta_information27                pay_us_emp_state_tax_rules_f.sta_information27%TYPE;
  l_sta_information28                pay_us_emp_state_tax_rules_f.sta_information28%TYPE;
  l_sta_information29                pay_us_emp_state_tax_rules_f.sta_information29%TYPE;
  l_sta_information30                pay_us_emp_state_tax_rules_f.sta_information30%TYPE;



  l_proc varchar2(72) := g_package||'create_state_tax_rule';
  l_effective_date         date;
  l_defaulting_date        pay_us_emp_state_tax_rules_f.effective_start_date%TYPE;
  l_def_pref               varchar2(30);
  l_dummy                  varchar2(5);
  --
  cursor csr_tax_defaulting_date is
     select min(fed.effective_start_date)
     from   pay_us_emp_fed_tax_rules_f fed
     where  fed.assignment_id = p_assignment_id;
  --
  cursor csr_state_tax_rule is
     select null
     from   pay_us_emp_state_tax_rules_f sta
     where  sta.assignment_id = p_assignment_id
     and    sta.state_code = p_state_code;
  --
  cursor csr_bus_grp is
     select asg.business_group_id
     from   per_assignments_f asg
     where  asg.assignment_id = p_assignment_id
     and    l_effective_date between asg.effective_start_date
            and asg.effective_end_date;
  --
  cursor csr_state_jd is
     select psr.jurisdiction_code
     from   pay_state_rules psr, pay_us_states pus
     where  pus.state_code = p_state_code
     and    pus.state_abbrev = psr.state_code;
  --
/*  cursor csr_filing_status is
     select hrl.lookup_code, peft.withholding_allowances
     from   HR_LOOKUPS hrl
     ,      PAY_US_EMP_FED_TAX_RULES_V peft
     where  hrl.lookup_type    = 'US_FS_'||p_state_code
     and    upper(hrl.meaning) = decode(
            upper(substr(peft.filing_status,1,7)),
                         'MARRIED',
                         'MARRIED',
                         upper(peft.filing_status))
     and    peft.assignment_id = p_assignment_id ;
*/

  cursor csr_filing_status is
     select flv.lookup_code, peft.withholding_allowances
     from   FND_LOOKUP_VALUES flv
     ,      PAY_US_EMP_FED_TAX_RULES_V peft
     where  flv.lookup_type    = 'US_FS_'||p_state_code
     and    upper(flv.meaning) = decode(
            upper(substr(peft.filing_status,1,7)),
                         'MARRIED',
                         'MARRIED',
                         upper(peft.filing_status))
     and    peft.assignment_id = p_assignment_id
     and flv.language = 'US'
     and flv.enabled_flag='Y';
  --
  cursor csr_fed_or_def is
     select hoi.org_information12
     from PAY_US_STATES pus,
          HR_ORGANIZATION_INFORMATION hoi,
          PER_ASSIGNMENTS_F paf,
          HR_SOFT_CODING_KEYFLEX hsck
     where paf.assignment_id = p_assignment_id
       and paf.soft_coding_keyflex_id = hsck.soft_coding_keyflex_id
       and hoi.organization_id = hsck.segment1
       and hoi.org_information_context = 'State Tax Rules'
       and hoi.org_information1 = pus.state_abbrev
       and pus.state_code = p_state_code;
  --
  -- Process Logic
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_state_tax_rule;

  --
  l_effective_date := trunc(p_effective_date);
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Validate the assignment_id passed in
  --
  open  csr_bus_grp;
  fetch csr_bus_grp into l_business_group_id;
  if csr_bus_grp%NOTFOUND then
    close csr_bus_grp;
    --
    -- The assignment does not exist in PER_ASSIGNMENTS_F
    --
    hr_utility.set_message(801, 'HR_51253_PYP_ASS__NOT_VALID');
    hr_utility.raise_error;
  end if;
  close csr_bus_grp;
  --
  -- Validation checks whether it is appropriate to run this process
  --
  open  csr_tax_defaulting_date;
  fetch csr_tax_defaulting_date into l_defaulting_date;
  close csr_tax_defaulting_date;
  if l_defaulting_date is null then
    --
    -- No Federal tax rule exists for this assignment
    --
    hr_utility.set_message(801, 'HR_7182_DT_NO_MIN_MAX_ROWS');
    hr_utility.set_message_token('TABLE_NAME','PAY_US_EMP_FED_TAX_RULES_F');
    hr_utility.raise_error;
  end if;
  --
  --
  open  csr_state_tax_rule;
  fetch csr_state_tax_rule into l_dummy;
  if csr_state_tax_rule%FOUND then
    close csr_state_tax_rule;
    --
    -- This state tax rule already exists
    --
    hr_utility.set_message(801, 'HR_7719_TAX_ONE_RULE_ONLY');
    hr_utility.raise_error;
  end if;
  close csr_state_tax_rule;
  --
  --
  open  csr_state_jd;
  fetch csr_state_jd into l_jurisdiction_code;
  if csr_state_jd%NOTFOUND then
    close csr_state_jd;
    --
    -- The jurisdiction_code for this state code cannot be found
    --      (Invalid state code)
    hr_utility.set_message(801, 'HR_7952_ADDR_NO_STATE_CODE');
    hr_utility.raise_error;
  end if;
  close csr_state_jd;
  --
  if p_default_flag = 'Y' then
  --
    open  csr_fed_or_def;
    --
    fetch csr_fed_or_def into l_def_pref;
    --
    hr_utility.set_location(l_proc,30);
    --
    if csr_fed_or_def%NOTFOUND then
      --
      CLOSE csr_fed_or_def;
        if p_state_code = '07' then
            hr_utility.set_location('pay_us_emp_dt_tax_rules.ins_def_state',41);
            l_filing_status_code := '07';
            l_withholding_allowances := 0;
        elsif p_state_code = '22' then
            hr_utility.set_location('pay_us_emp_dt_tax_rules.ins_def_state',42);
            l_filing_status_code := '04';
            l_withholding_allowances := 0;
        else
	    l_filing_status_code := '01';
	    l_withholding_allowances := 0;
            hr_utility.set_location(l_proc,43);
        end if;
    elsif csr_fed_or_def%FOUND then
      --
      CLOSE csr_fed_or_def;
      --
      if l_def_pref = 'SINGLE_ZERO' or l_def_pref is null then
        --
        if p_state_code = '07' then
            hr_utility.set_location('pay_us_emp_dt_tax_rules.ins_def_state',51);
            l_filing_status_code := '07';
            l_withholding_allowances := 0;
        elsif p_state_code = '22' then
            hr_utility.set_location('pay_us_emp_dt_tax_rules.ins_def_state',52);
            l_filing_status_code := '04';
            l_withholding_allowances := 0;
        else
            hr_utility.set_location(l_proc,53);
            l_filing_status_code := '01';
            l_withholding_allowances         := 0;
	end if;
        --
      elsif l_def_pref = 'FED_DEF' then
        --
        hr_utility.set_location(l_proc,60);
        open  csr_filing_status;
        --
        fetch csr_filing_status into l_filing_status_code, l_withholding_allowances;
        l_filing_status_code := lpad(l_filing_status_code,2,'0');
        --
        if csr_filing_status%NOTFOUND then
          --
	    if p_state_code = '07' then
                hr_utility.set_location('pay_us_emp_dt_tax_rules.ins_def_state',71);
                l_filing_status_code := '07';
                l_withholding_allowances := 0;
            elsif p_state_code = '22' then
                hr_utility.set_location('pay_us_emp_dt_tax_rules.ins_def_state',72);
                l_filing_status_code := '04';
                l_withholding_allowances := 0;
            else
	        hr_utility.set_location(l_proc,73);
                l_filing_status_code := '01';
                l_withholding_allowances := 0;
	    end if;
          --
        end if;
        --
        close csr_filing_status;
        --
      end if;  -- l_def_pref
      --
    end if;    -- csr_fed_or_def found?
    --
    l_additional_wa_amount         := 0;
    l_remainder_percent            := 0;
    l_secondary_wa                 := 0;
    l_sit_additional_tax           := 0;
    l_sit_override_amount          := 0;
    l_sit_override_rate            := 0;
    l_sdi_exempt                   := 'N';
    l_sit_exempt                   := 'N';
    l_sui_exempt                   := 'N';
    l_wage_exempt                  := 'N';
    l_supp_tax_override_rate       := 0;
    l_attribute_category           := NULL;
    l_attribute1                   := NULL;
    l_attribute2                   := NULL;
    l_attribute3                   := NULL;
    l_attribute4                   := NULL;
    l_attribute5                   := NULL;
    l_attribute6                   := NULL;
    l_attribute7                   := NULL;
    l_attribute8                   := NULL;
    l_attribute9                   := NULL;
    l_attribute10                  := NULL;
    l_attribute11                  := NULL;
    l_attribute12                  := NULL;
    l_attribute13                  := NULL;
    l_attribute14                  := NULL;
    l_attribute15                  := NULL;
    l_attribute16                  := NULL;
    l_attribute17                  := NULL;
    l_attribute18                  := NULL;
    l_attribute19                  := NULL;
    l_attribute20                  := NULL;
    l_attribute21                  := NULL;
    l_attribute22                  := NULL;
    l_attribute23                  := NULL;
    l_attribute24                  := NULL;
    l_attribute25                  := NULL;
    l_attribute26                  := NULL;
    l_attribute27                  := NULL;
    l_attribute28                  := NULL;
    l_attribute29                  := NULL;
    l_attribute30                  := NULL;
    l_sta_information_category     := NULL;
    l_sta_information1             := NULL;
    l_sta_information2             := NULL;
    l_sta_information3             := NULL;
    l_sta_information4             := NULL;
    l_sta_information5             := NULL;
    l_sta_information6             := NULL;
    l_sta_information7             := NULL;
    l_sta_information8             := NULL;
    l_sta_information9             := NULL;
    l_sta_information10            := NULL;
    l_sta_information11            := NULL;
    l_sta_information12            := NULL;
    l_sta_information13            := NULL;
    l_sta_information14            := NULL;
    l_sta_information15            := NULL;
    l_sta_information16            := NULL;
    l_sta_information17            := NULL;
    l_sta_information18            := NULL;
    l_sta_information19            := NULL;
    l_sta_information20            := NULL;
    l_sta_information21            := NULL;
    l_sta_information22            := NULL;
    l_sta_information23            := NULL;
    l_sta_information24            := NULL;
    l_sta_information25            := NULL;
    l_sta_information26            := NULL;
    l_sta_information27            := NULL;
    l_sta_information28            := NULL;
    l_sta_information29            := NULL;
    l_sta_information30            := NULL;
    --
  else
    l_additional_wa_amount         := p_additional_wa_amount;
    l_filing_status_code           := p_filing_status_code;
    l_remainder_percent            := p_remainder_percent;
    l_secondary_wa                 := p_secondary_wa;
    l_sit_additional_tax           := p_sit_additional_tax;
    l_sit_override_amount          := p_sit_override_amount;
    l_sit_override_rate            := p_sit_override_rate;
    l_withholding_allowances       := p_withholding_allowances;
    l_excessive_wa_reject_date     := trunc(p_excessive_wa_reject_date);
    l_sdi_exempt                   := p_sdi_exempt;
    l_sit_exempt                   := p_sit_exempt;
    l_sit_optional_calc_ind        := p_sit_optional_calc_ind;
    l_state_non_resident_cert      := p_state_non_resident_cert;
    l_sui_exempt                   := p_sui_exempt;
    l_wc_exempt                    := p_wc_exempt;
    l_wage_exempt                  := p_wage_exempt;
    l_sui_wage_base_override_amoun := p_sui_wage_base_override_amoun;
    l_supp_tax_override_rate       := p_supp_tax_override_rate;
    l_attribute_category           := p_attribute_category;
    l_attribute1                   := p_attribute1;
    l_attribute2                   := p_attribute2;
    l_attribute3                   := p_attribute3;
    l_attribute4                   := p_attribute4;
    l_attribute5                   := p_attribute5;
    l_attribute6                   := p_attribute6;
    l_attribute7                   := p_attribute7;
    l_attribute8                   := p_attribute8;
    l_attribute9                   := p_attribute9;
    l_attribute10                  := p_attribute10;
    l_attribute11                  := p_attribute11;
    l_attribute12                  := p_attribute12;
    l_attribute13                  := p_attribute13;
    l_attribute14                  := p_attribute14;
    l_attribute15                  := p_attribute15;
    l_attribute16                  := p_attribute16;
    l_attribute17                  := p_attribute17;
    l_attribute18                  := p_attribute18;
    l_attribute19                  := p_attribute19;
    l_attribute20                  := p_attribute20;
    l_attribute21                  := p_attribute21;
    l_attribute22                  := p_attribute22;
    l_attribute23                  := p_attribute23;
    l_attribute24                  := p_attribute24;
    l_attribute25                  := p_attribute25;
    l_attribute26                  := p_attribute26;
    l_attribute27                  := p_attribute27;
    l_attribute28                  := p_attribute28;
    l_attribute29                  := p_attribute29;
    l_attribute30                  := p_attribute30;
    l_sta_information_category     := p_sta_information_category;
    l_sta_information1             := p_sta_information1;
    l_sta_information2             := p_sta_information2;
    l_sta_information3             := p_sta_information3;
    l_sta_information4             := p_sta_information4;
    l_sta_information5             := p_sta_information5;
    l_sta_information6             := p_sta_information6;
    l_sta_information7             := p_sta_information7;
    l_sta_information8             := p_sta_information8;
    l_sta_information9             := p_sta_information9;
    l_sta_information10            := p_sta_information10;
    l_sta_information11            := p_sta_information11;
    l_sta_information12            := p_sta_information12;
    l_sta_information13            := p_sta_information13;
    l_sta_information14            := p_sta_information14;
    l_sta_information15            := p_sta_information15;
    l_sta_information16            := p_sta_information16;
    l_sta_information17            := p_sta_information17;
    l_sta_information18            := p_sta_information18;
    l_sta_information19            := p_sta_information19;
    l_sta_information20            := p_sta_information20;
    l_sta_information21            := p_sta_information21;
    l_sta_information22            := p_sta_information22;
    l_sta_information23            := p_sta_information23;
    l_sta_information24            := p_sta_information24;
    l_sta_information25            := p_sta_information25;
    l_sta_information26            := p_sta_information26;
    l_sta_information27            := p_sta_information27;
    l_sta_information28            := p_sta_information28;
    l_sta_information29            := p_sta_information29;
    l_sta_information30            := p_sta_information30;
    --
  end if;  -- p_default_flag
  --
--  begin
    --
    -- Start of API User Hook for the before hook of create_state_tax_rule
    --
--    pay_sta_bk1.create_state_tax_rule_b
--      (
--       p_assignment_id                  =>  p_assignment_id
--      ,p_state_code                     =>  p_state_code
--      ,p_jurisdiction_code              =>  l_jurisdiction_code
--      ,p_business_group_id              =>  l_business_group_id
--      ,p_additional_wa_amount           =>  l_additional_wa_amount
--      ,p_filing_status_code             =>  l_filing_status_code
--      ,p_remainder_percent              =>  l_remainder_percent
--      ,p_secondary_wa                   =>  l_secondary_wa
--      ,p_sit_additional_tax             =>  l_sit_additional_tax
--      ,p_sit_override_amount            =>  l_sit_override_amount
--      ,p_sit_override_rate              =>  l_sit_override_rate
--      ,p_withholding_allowances         =>  l_withholding_allowances
--      ,p_excessive_wa_reject_date       =>  l_excessive_wa_reject_date
--      ,p_sdi_exempt                     =>  l_sdi_exempt
--      ,p_sit_exempt                     =>  l_sit_exempt
--      ,p_sit_optional_calc_ind          =>  l_sit_optional_calc_ind
--      ,p_state_non_resident_cert        =>  l_state_non_resident_cert
--      ,p_sui_exempt                     =>  l_sui_exempt
--      ,p_wc_exempt                      =>  l_wc_exempt
--      ,p_wage_exempt                    =>  l_wage_exempt
--      ,p_sui_wage_base_override_amoun   =>  l_sui_wage_base_override_amoun
--      ,p_supp_tax_override_rate         =>  l_supp_tax_override_rate
--      );
--  exception
--    when hr_api.cannot_find_prog_unit then
--      hr_api.cannot_find_prog_unit_error
--        (
--         p_module_name => 'create_state_tax_rule'
--        ,p_hook_type   => 'BP'
--        );
    --
    -- End of API User Hook for the before hook of create_state_tax_rule
    --
--  end;
  --
  -- Insert State Tax record
  --
  hr_utility.set_location(l_proc,80);
  --
  --
  pay_sta_ins.ins
    (
     p_emp_state_tax_rule_id         => l_emp_state_tax_rule_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_assignment_id                 => p_assignment_id
    ,p_state_code                    => p_state_code
    ,p_jurisdiction_code             => l_jurisdiction_code
    ,p_business_group_id             => l_business_group_id
    ,p_additional_wa_amount          => l_additional_wa_amount
    ,p_filing_status_code            => l_filing_status_code
    ,p_remainder_percent             => l_remainder_percent
    ,p_secondary_wa                  => l_secondary_wa
    ,p_sit_additional_tax            => l_sit_additional_tax
    ,p_sit_override_amount           => l_sit_override_amount
    ,p_sit_override_rate             => l_sit_override_rate
    ,p_withholding_allowances        => l_withholding_allowances
    ,p_excessive_wa_reject_date      => l_excessive_wa_reject_date
    ,p_sdi_exempt                    => l_sdi_exempt
    ,p_sit_exempt                    => l_sit_exempt
    ,p_sit_optional_calc_ind         => l_sit_optional_calc_ind
    ,p_state_non_resident_cert       => l_state_non_resident_cert
    ,p_sui_exempt                    => l_sui_exempt
    ,p_wc_exempt                     => l_wc_exempt
    ,p_wage_exempt                   => l_wage_exempt
    ,p_sui_wage_base_override_amoun  => l_sui_wage_base_override_amoun
    ,p_supp_tax_override_rate        => l_supp_tax_override_rate
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => l_defaulting_date
    ,p_attribute_category            => l_attribute_category
    ,p_attribute1                    => l_attribute1
    ,p_attribute2                    => l_attribute2
    ,p_attribute3                    => l_attribute3
    ,p_attribute4                    => l_attribute4
    ,p_attribute5                    => l_attribute5
    ,p_attribute6                    => l_attribute6
    ,p_attribute7                    => l_attribute7
    ,p_attribute8                    => l_attribute8
    ,p_attribute9                    => l_attribute9
    ,p_attribute10                   => l_attribute10
    ,p_attribute11                   => l_attribute11
    ,p_attribute12                   => l_attribute12
    ,p_attribute13                   => l_attribute13
    ,p_attribute14                   => l_attribute14
    ,p_attribute15                   => l_attribute15
    ,p_attribute16                   => l_attribute16
    ,p_attribute17                   => l_attribute17
    ,p_attribute18                   => l_attribute18
    ,p_attribute19                   => l_attribute19
    ,p_attribute20                   => l_attribute20
    ,p_attribute21                   => l_attribute21
    ,p_attribute22                   => l_attribute22
    ,p_attribute23                   => l_attribute23
    ,p_attribute24                   => l_attribute24
    ,p_attribute25                   => l_attribute25
    ,p_attribute26                   => l_attribute26
    ,p_attribute27                   => l_attribute27
    ,p_attribute28                   => l_attribute28
    ,p_attribute29                   => l_attribute29
    ,p_attribute30                   => l_attribute30
    ,p_sta_information_category      => l_sta_information_category
    ,p_sta_information1                    => l_sta_information1
    ,p_sta_information2                    => l_sta_information2
    ,p_sta_information3                    => l_sta_information3
    ,p_sta_information4                    => l_sta_information4
    ,p_sta_information5                    => l_sta_information5
    ,p_sta_information6                    => l_sta_information6
    ,p_sta_information7                    => l_sta_information7
    ,p_sta_information8                    => l_sta_information8
    ,p_sta_information9                    => l_sta_information9
    ,p_sta_information10                   => l_sta_information10
    ,p_sta_information11                   => l_sta_information11
    ,p_sta_information12                   => l_sta_information12
    ,p_sta_information13                   => l_sta_information13
    ,p_sta_information14                   => l_sta_information14
    ,p_sta_information15                   => l_sta_information15
    ,p_sta_information16                   => l_sta_information16
    ,p_sta_information17                   => l_sta_information17
    ,p_sta_information18                   => l_sta_information18
    ,p_sta_information19                   => l_sta_information19
    ,p_sta_information20                   => l_sta_information20
    ,p_sta_information21                   => l_sta_information21
    ,p_sta_information22                   => l_sta_information22
    ,p_sta_information23                   => l_sta_information23
    ,p_sta_information24                   => l_sta_information24
    ,p_sta_information25                   => l_sta_information25
    ,p_sta_information26                   => l_sta_information26
    ,p_sta_information27                   => l_sta_information27
    ,p_sta_information28                   => l_sta_information28
    ,p_sta_information29                   => l_sta_information29
    ,p_sta_information30                   => l_sta_information30
    );
  --
  -- Create tax %age element entry for the state
  --
  pay_us_tax_internal.maintain_tax_percentage(
               p_assignment_id        => p_assignment_id
              ,p_effective_date       => l_effective_date
              ,p_state_code           => p_state_code
              ,p_county_code          => '000'
              ,p_city_code            => '0000'
              ,p_datetrack_mode       => 'INSERT'
              ,p_effective_start_date => l_effective_start_date
              ,p_effective_end_date   => l_effective_end_date
              ,p_calculate_pct        => FALSE
              );
  --
  -- Call create_asg_geo_row to create rows in the pay_us_asg_reporting
  -- table if this is a new state
  --
  pay_asg_geo_pkg.create_asg_geo_row(
               p_assignment_id => p_assignment_id
              ,p_jurisdiction  => l_jurisdiction_code
              );
  --
--  begin
    --
    -- Start of API User Hook for the after hook of create_state_tax_rule
    --
--    pay_sta_bk1.create_state_tax_rule_a
--      (
--       p_emp_state_tax_rule_id          =>  l_emp_state_tax_rule_id
--      ,p_effective_start_date           =>  l_effective_start_date
--      ,p_effective_end_date             =>  l_effective_end_date
--      ,p_assignment_id                  =>  p_assignment_id
--      ,p_state_code                     =>  p_state_code
--      ,p_jurisdiction_code              =>  l_jurisdiction_code
--      ,p_business_group_id              =>  l_business_group_id
--      ,p_additional_wa_amount           =>  l_additional_wa_amount
--      ,p_filing_status_code             =>  l_filing_status_code
--      ,p_remainder_percent              =>  l_remainder_percent
--      ,p_secondary_wa                   =>  l_secondary_wa
--      ,p_sit_additional_tax             =>  l_sit_additional_tax
--      ,p_sit_override_amount            =>  l_sit_override_amount
--      ,p_sit_override_rate              =>  l_sit_override_rate
--      ,p_withholding_allowances         =>  l_withholding_allowances
--      ,p_excessive_wa_reject_date       =>  l_excessive_wa_reject_date
--      ,p_sdi_exempt                     =>  l_sdi_exempt
--      ,p_sit_exempt                     =>  l_sit_exempt
--      ,p_sit_optional_calc_ind          =>  l_sit_optional_calc_ind
--      ,p_state_non_resident_cert        =>  l_state_non_resident_cert
--      ,p_sui_exempt                     =>  l_sui_exempt
--      ,p_wc_exempt                      =>  l_wc_exempt
--      ,p_wage_exempt                    =>  l_wage_exempt
--      ,p_sui_wage_base_override_amoun   =>  l_sui_wage_base_override_amoun
--      ,p_supp_tax_override_rate         =>  l_supp_tax_override_rate
--      ,p_object_version_number          =>  l_object_version_number
--      );
--  exception
--    when hr_api.cannot_find_prog_unit then
--      hr_api.cannot_find_prog_unit_error
--        (p_module_name => 'create_state_tax_rule'
--        ,p_hook_type   => 'AP'
--        );
    --
    -- End of API User Hook for the after hook of create_state_tax_rule
    --
--  end;
  --
  hr_utility.set_location(l_proc, 90);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_emp_state_tax_rule_id := l_emp_state_tax_rule_id;
  p_effective_start_date := l_effective_start_date;
  p_effective_end_date := l_effective_end_date;
  p_object_version_number := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 100);
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_state_tax_rule;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_emp_state_tax_rule_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 120);
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    ROLLBACK TO create_state_tax_rule;
    --
    --  as per nocopy implementation guidelines re-set all
    --  out parameters to null
    --
    p_emp_state_tax_rule_id := null;
    p_object_version_number := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    --
    raise;
    --
end create_state_tax_rule;

-- ----------------------------------------------------------------------------
-- |------------------------< update_state_tax_rule >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_state_tax_rule
(
   p_validate                       in     boolean    default false
  ,p_effective_date                 in     date
  ,p_datetrack_update_mode          in     varchar2
  ,p_emp_state_tax_rule_id          in     number
  ,p_object_version_number          in out nocopy number
  ,p_additional_wa_amount           in     number    default hr_api.g_number
  ,p_filing_status_code             in     varchar2  default hr_api.g_varchar2
  ,p_remainder_percent              in     number    default hr_api.g_number
  ,p_secondary_wa                   in     number    default hr_api.g_number
  ,p_sit_additional_tax             in     number    default hr_api.g_number
  ,p_sit_override_amount            in     number    default hr_api.g_number
  ,p_sit_override_rate              in     number    default hr_api.g_number
  ,p_withholding_allowances         in     number    default hr_api.g_number
  ,p_excessive_wa_reject_date       in     date      default hr_api.g_date
  ,p_sdi_exempt                     in     varchar2  default hr_api.g_varchar2
  ,p_sit_exempt                     in     varchar2  default hr_api.g_varchar2
  ,p_sit_optional_calc_ind          in     varchar2  default hr_api.g_varchar2
  ,p_state_non_resident_cert        in     varchar2  default hr_api.g_varchar2
  ,p_sui_exempt                     in     varchar2  default hr_api.g_varchar2
  ,p_wc_exempt                      in     varchar2  default hr_api.g_varchar2
  ,p_wage_exempt                    in     varchar2  default hr_api.g_varchar2
  ,p_sui_wage_base_override_amoun   in     number    default hr_api.g_number
  ,p_supp_tax_override_rate         in     number    default hr_api.g_number
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
  ,p_sta_information_category       in     varchar2  default hr_api.g_varchar2
  ,p_sta_information1               in     varchar2  default hr_api.g_varchar2
  ,p_sta_information2               in     varchar2  default hr_api.g_varchar2
  ,p_sta_information3               in     varchar2  default hr_api.g_varchar2
  ,p_sta_information4               in     varchar2  default hr_api.g_varchar2
  ,p_sta_information5               in     varchar2  default hr_api.g_varchar2
  ,p_sta_information6               in     varchar2  default hr_api.g_varchar2
  ,p_sta_information7               in     varchar2  default hr_api.g_varchar2
  ,p_sta_information8               in     varchar2  default hr_api.g_varchar2
  ,p_sta_information9               in     varchar2  default hr_api.g_varchar2
  ,p_sta_information10              in     varchar2  default hr_api.g_varchar2
  ,p_sta_information11              in     varchar2  default hr_api.g_varchar2
  ,p_sta_information12              in     varchar2  default hr_api.g_varchar2
  ,p_sta_information13              in     varchar2  default hr_api.g_varchar2
  ,p_sta_information14              in     varchar2  default hr_api.g_varchar2
  ,p_sta_information15              in     varchar2  default hr_api.g_varchar2
  ,p_sta_information16              in     varchar2  default hr_api.g_varchar2
  ,p_sta_information17              in     varchar2  default hr_api.g_varchar2
  ,p_sta_information18              in     varchar2  default hr_api.g_varchar2
  ,p_sta_information19              in     varchar2  default hr_api.g_varchar2
  ,p_sta_information20              in     varchar2  default hr_api.g_varchar2
  ,p_sta_information21              in     varchar2  default hr_api.g_varchar2
  ,p_sta_information22              in     varchar2  default hr_api.g_varchar2
  ,p_sta_information23              in     varchar2  default hr_api.g_varchar2
  ,p_sta_information24              in     varchar2  default hr_api.g_varchar2
  ,p_sta_information25              in     varchar2  default hr_api.g_varchar2
  ,p_sta_information26              in     varchar2  default hr_api.g_varchar2
  ,p_sta_information27              in     varchar2  default hr_api.g_varchar2
  ,p_sta_information28              in     varchar2  default hr_api.g_varchar2
  ,p_sta_information29              in     varchar2  default hr_api.g_varchar2
  ,p_sta_information30              in     varchar2  default hr_api.g_varchar2
  ,p_effective_start_date              out nocopy date
  ,p_effective_end_date                out nocopy date
 ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_state_tax_rule';
  l_effective_date          date;
  l_excessive_wa_reject_date date;
  l_object_version_number   pay_us_emp_state_tax_rules_f.object_version_number%TYPE;
  l_effective_start_date    pay_us_emp_state_tax_rules_f.effective_start_date%TYPE;
  l_effective_end_date      pay_us_emp_state_tax_rules_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_state_tax_rule;

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
  -- Change chk_geocodes_installed to  hr_general.chk_maintain_tax_records
  -- to determine if we need to maintain tax records.
  --
  IF  hr_general.chk_maintain_tax_records = 'N' Then
     return;
  end if;
    --
--  begin
    --
    -- Start of API User Hook for the before hook of update_state_tax_rule
    --
--    pay_sta_bk2.update_state_tax_rule_b
--      (
--       p_emp_state_tax_rule_id          =>  p_emp_state_tax_rule_id
--      ,p_assignment_id                  =>  p_assignment_id
--      ,p_state_code                     =>  p_state_code
--      ,p_jurisdiction_code              =>  p_jurisdiction_code
--      ,p_business_group_id              =>  p_business_group_id
--      ,p_additional_wa_amount           =>  p_additional_wa_amount
--      ,p_filing_status_code             =>  p_filing_status_code
--      ,p_remainder_percent              =>  p_remainder_percent
--      ,p_secondary_wa                   =>  p_secondary_wa
--      ,p_sit_additional_tax             =>  p_sit_additional_tax
--      ,p_sit_override_amount            =>  p_sit_override_amount
--      ,p_sit_override_rate              =>  p_sit_override_rate
--      ,p_withholding_allowances         =>  p_withholding_allowances
--      ,p_excessive_wa_reject_date       =>  l_excessive_wa_reject_date
--      ,p_sdi_exempt                     =>  p_sdi_exempt
--      ,p_sit_exempt                     =>  p_sit_exempt
--      ,p_sit_optional_calc_ind          =>  p_sit_optional_calc_ind
--      ,p_state_non_resident_cert        =>  p_state_non_resident_cert
--      ,p_sui_exempt                     =>  p_sui_exempt
--      ,p_wc_exempt                      =>  p_wc_exempt
--      ,p_wage_exempt                    =>  p_wage_exempt
--      ,p_sui_wage_base_override_amoun   =>  p_sui_wage_base_override_amoun
--      ,p_supp_tax_override_rate         =>  p_supp_tax_override_rate
--      ,p_object_version_number          =>  p_object_version_number
--      );
--  exception
--    when hr_api.cannot_find_prog_unit then
--      hr_api.cannot_find_prog_unit_error
--        (p_module_name => 'update_state_tax_rule'
--        ,p_hook_type   => 'BP'
--        );
    --
    -- End of API User Hook for the before hook of update_state_tax_rule
    --
--  end;
  --
  --
  pay_sta_upd.upd
    (
     p_emp_state_tax_rule_id         => p_emp_state_tax_rule_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_additional_wa_amount          => p_additional_wa_amount
    ,p_filing_status_code            => p_filing_status_code
    ,p_remainder_percent             => p_remainder_percent
    ,p_secondary_wa                  => p_secondary_wa
    ,p_sit_additional_tax            => p_sit_additional_tax
    ,p_sit_override_amount           => p_sit_override_amount
    ,p_sit_override_rate             => p_sit_override_rate
    ,p_withholding_allowances        => p_withholding_allowances
    ,p_excessive_wa_reject_date      => l_excessive_wa_reject_date
    ,p_sdi_exempt                    => p_sdi_exempt
    ,p_sit_exempt                    => p_sit_exempt
    ,p_sit_optional_calc_ind         => p_sit_optional_calc_ind
    ,p_state_non_resident_cert       => p_state_non_resident_cert
    ,p_sui_exempt                    => p_sui_exempt
    ,p_wc_exempt                     => p_wc_exempt
    ,p_wage_exempt                   => p_wage_exempt
    ,p_sui_wage_base_override_amoun  => p_sui_wage_base_override_amoun
    ,p_supp_tax_override_rate        => p_supp_tax_override_rate
    ,p_object_version_number         => p_object_version_number
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
    ,p_sta_information_category      => p_sta_information_category
    ,p_sta_information1                    => p_sta_information1
    ,p_sta_information2                    => p_sta_information2
    ,p_sta_information3                    => p_sta_information3
    ,p_sta_information4                    => p_sta_information4
    ,p_sta_information5                    => p_sta_information5
    ,p_sta_information6                    => p_sta_information6
    ,p_sta_information7                    => p_sta_information7
    ,p_sta_information8                    => p_sta_information8
    ,p_sta_information9                    => p_sta_information9
    ,p_sta_information10                   => p_sta_information10
    ,p_sta_information11                   => p_sta_information11
    ,p_sta_information12                   => p_sta_information12
    ,p_sta_information13                   => p_sta_information13
    ,p_sta_information14                   => p_sta_information14
    ,p_sta_information15                   => p_sta_information15
    ,p_sta_information16                   => p_sta_information16
    ,p_sta_information17                   => p_sta_information17
    ,p_sta_information18                   => p_sta_information18
    ,p_sta_information19                   => p_sta_information19
    ,p_sta_information20                   => p_sta_information20
    ,p_sta_information21                   => p_sta_information21
    ,p_sta_information22                   => p_sta_information22
    ,p_sta_information23                   => p_sta_information23
    ,p_sta_information24                   => p_sta_information24
    ,p_sta_information25                   => p_sta_information25
    ,p_sta_information26                   => p_sta_information26
    ,p_sta_information27                   => p_sta_information27
    ,p_sta_information28                   => p_sta_information28
    ,p_sta_information29                   => p_sta_information29
    ,p_sta_information30                   => p_sta_information30
    ,p_effective_date                => l_effective_date
    ,p_datetrack_mode                => p_datetrack_update_mode
    );
  --
  --
--  begin
    --
    -- Start of API User Hook for the after hook of update_state_tax_rule
    --
--    pay_sta_bk2.update_state_tax_rule_a
--      (
--       p_emp_state_tax_rule_id          =>  p_emp_state_tax_rule_id
--      ,p_effective_start_date           =>  l_effective_start_date
--      ,p_effective_end_date             =>  l_effective_end_date
--      ,p_assignment_id                  =>  p_assignment_id
--      ,p_state_code                     =>  p_state_code
--      ,p_jurisdiction_code              =>  p_jurisdiction_code
--      ,p_business_group_id              =>  p_business_group_id
--      ,p_additional_wa_amount           =>  p_additional_wa_amount
--      ,p_filing_status_code             =>  p_filing_status_code
--      ,p_remainder_percent              =>  p_remainder_percent
--      ,p_secondary_wa                   =>  p_secondary_wa
--      ,p_sit_additional_tax             =>  p_sit_additional_tax
--      ,p_sit_override_amount            =>  p_sit_override_amount
--      ,p_sit_override_rate              =>  p_sit_override_rate
--      ,p_withholding_allowances         =>  p_withholding_allowances
--      ,p_excessive_wa_reject_date       =>  l_excessive_wa_reject_date
--      ,p_sdi_exempt                     =>  p_sdi_exempt
--      ,p_sit_exempt                     =>  p_sit_exempt
--      ,p_sit_optional_calc_ind          =>  p_sit_optional_calc_ind
--      ,p_state_non_resident_cert        =>  p_state_non_resident_cert
--      ,p_sui_exempt                     =>  p_sui_exempt
--      ,p_wc_exempt                      =>  p_wc_exempt
--      ,p_wage_exempt                    =>  p_wage_exempt
--      ,p_sui_wage_base_override_amoun   =>  p_sui_wage_base_override_amoun
--      ,p_supp_tax_override_rate         =>  p_supp_tax_override_rate
--      ,p_object_version_number          =>  p_object_version_number
--      );
--  exception
--    when hr_api.cannot_find_prog_unit then
--      hr_api.cannot_find_prog_unit_error
--        (p_module_name => 'update_state_tax_rule'
--        ,p_hook_type   => 'AP'
--        );
    --
    -- End of API User Hook for the after hook of update_state_tax_rule
    --
--  end;
  --
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
  --  p_object_version_number := l_object_version_number;
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
    ROLLBACK TO update_state_tax_rule;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number := l_object_version_number;
    p_effective_start_date := null;
    p_effective_end_date := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    ROLLBACK TO update_state_tax_rule;
    --
    --  as per nocopy implementation guidelines re-set
    --  out parameters to null
    --
    p_object_version_number := l_object_version_number;
    p_effective_start_date := null;
    p_effective_end_date := null;
    --
    raise;
    --
end update_state_tax_rule;

--
end pay_state_tax_rule_api;

/
