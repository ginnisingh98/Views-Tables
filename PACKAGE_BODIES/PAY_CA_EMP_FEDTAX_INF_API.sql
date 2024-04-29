--------------------------------------------------------
--  DDL for Package Body PAY_CA_EMP_FEDTAX_INF_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CA_EMP_FEDTAX_INF_API" as
/* $Header: pycatapi.pkb 120.1.12010000.1 2008/07/27 22:17:47 appldev ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  pay_ca_emp_fedtax_inf_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_ca_emp_fedtax_inf >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_ca_emp_fedtax_inf
  (p_validate                       in  boolean   default false
  ,p_emp_fed_tax_inf_id             out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_legislation_code               in  varchar2
  ,p_assignment_id                  in  number
  ,p_business_group_id              in  number
  ,p_employment_province            in  varchar2  default null
  ,p_tax_credit_amount              in  number    default null
  ,p_claim_code                     in  varchar2  default null
  ,p_basic_exemption_flag           in  varchar2  default null
  ,p_additional_tax                 in  number    default null
  ,p_annual_dedn                    in  number    default null
  ,p_total_expense_by_commission    in  number    default null
  ,p_total_remnrtn_by_commission    in  number    default null
  ,p_prescribed_zone_dedn_amt       in  number    default null
  ,p_other_fedtax_credits           in  varchar2  default null
  ,p_cpp_qpp_exempt_flag            in  varchar2  default null
  ,p_fed_exempt_flag                in  varchar2  default null
  ,p_ei_exempt_flag                 in  varchar2  default null
  ,p_tax_calc_method                in  varchar2  default null
  ,p_fed_override_amount            in  number    default null
  ,p_fed_override_rate              in  number    default null
  ,p_ca_tax_information_category    in  varchar2  default null
  ,p_ca_tax_information1            in  varchar2  default null
  ,p_ca_tax_information2            in  varchar2  default null
  ,p_ca_tax_information3            in  varchar2  default null
  ,p_ca_tax_information4            in  varchar2  default null
  ,p_ca_tax_information5            in  varchar2  default null
  ,p_ca_tax_information6            in  varchar2  default null
  ,p_ca_tax_information7            in  varchar2  default null
  ,p_ca_tax_information8            in  varchar2  default null
  ,p_ca_tax_information9            in  varchar2  default null
  ,p_ca_tax_information10           in  varchar2  default null
  ,p_ca_tax_information11           in  varchar2  default null
  ,p_ca_tax_information12           in  varchar2  default null
  ,p_ca_tax_information13           in  varchar2  default null
  ,p_ca_tax_information14           in  varchar2  default null
  ,p_ca_tax_information15           in  varchar2  default null
  ,p_ca_tax_information16           in  varchar2  default null
  ,p_ca_tax_information17           in  varchar2  default null
  ,p_ca_tax_information18           in  varchar2  default null
  ,p_ca_tax_information19           in  varchar2  default null
  ,p_ca_tax_information20           in  varchar2  default null
  ,p_ca_tax_information21           in  varchar2  default null
  ,p_ca_tax_information22           in  varchar2  default null
  ,p_ca_tax_information23           in  varchar2  default null
  ,p_ca_tax_information24           in  varchar2  default null
  ,p_ca_tax_information25           in  varchar2  default null
  ,p_ca_tax_information26           in  varchar2  default null
  ,p_ca_tax_information27           in  varchar2  default null
  ,p_ca_tax_information28           in  varchar2  default null
  ,p_ca_tax_information29           in  varchar2  default null
  ,p_ca_tax_information30           in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_fed_lsf_amount                 in  number    default null
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_emp_fed_tax_inf_id   pay_ca_emp_fed_tax_info_f.emp_fed_tax_inf_id%TYPE;
  l_effective_start_date pay_ca_emp_fed_tax_info_f.effective_start_date%TYPE;
  l_effective_end_date   pay_ca_emp_fed_tax_info_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_ca_emp_fedtax_inf';
  l_object_version_number pay_ca_emp_fed_tax_info_f.object_version_number%TYPE;
  l_rec_present varchar2(1);
  l_tax_credit_amount   number  := 0;
  l_additional_tax   number   := 0;
  l_annual_dedn     number   := 0;
  l_total_expense_by_commission    number   := 0;
  l_total_remnrtn_by_commission   number   := 0;
  l_prescribed_zone_dedn_amt   number   := 0;
  l_other_fedtax_credits      number   := 0;
  l_fed_override_amount      number   := 0;
  l_fed_override_rate      number   := 0;
  l_fed_lsf_amount   number  := 0;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_ca_emp_fedtax_inf;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --

  perform_assignment_validation(p_assignment_id => p_assignment_id,
                                p_effective_date => p_effective_date);

--
  tax_record_already_present(p_assignment_id => p_assignment_id,
                             p_effective_date => p_effective_date,
                             p_rec_present => l_rec_present); /* added*/

if l_rec_present <> 'Y' then
/* Defaulting all the number fields which are null */
hr_utility.trace('call rowhandler');
   l_tax_credit_amount := convert_null_to_zero(p_tax_credit_amount);
   l_additional_tax := convert_null_to_zero(p_additional_tax);
   l_annual_dedn    := convert_null_to_zero(p_annual_dedn);
   l_total_expense_by_commission  := convert_null_to_zero(p_total_expense_by_commission);
   l_total_remnrtn_by_commission  := convert_null_to_zero(p_total_remnrtn_by_commission);
   l_prescribed_zone_dedn_amt := convert_null_to_zero(p_prescribed_zone_dedn_amt);
   l_other_fedtax_credits    := convert_null_to_zero(p_other_fedtax_credits);
   l_fed_override_amount    := convert_null_to_zero(p_fed_override_amount);
   l_fed_override_rate    := convert_null_to_zero(p_fed_override_rate);
   l_fed_lsf_amount := convert_null_to_zero(p_fed_lsf_amount);
hr_utility.trace('call rowhandler');
/*
  begin
    --
    -- Start of API User Hook for the before hook of create_ca_emp_fedtax_inf
    --
    pay_ca_emp_fedtax_inf_bk1.create_ca_emp_fedtax_inf_b
      (
       p_legislation_code               =>  p_legislation_code
      ,p_assignment_id                  =>  p_assignment_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_employment_province            =>  p_employment_province
      ,p_tax_credit_amount              =>  p_tax_credit_amount
      ,p_claim_code                     =>  p_claim_code
      ,p_basic_exemption_flag           =>  p_basic_exemption_flag
      ,p_additional_tax                 =>  l_additional_tax
      ,p_annual_dedn                    =>  l_annual_dedn
      ,p_total_expense_by_commission    =>  l_total_expense_by_commission
      ,p_total_remnrtn_by_commission    =>  l_total_remnrtn_by_commission
      ,p_prescribed_zone_dedn_amt       =>  l_prescribed_zone_dedn_amt
      ,p_other_fedtax_credits           =>  l_other_fedtax_credits
      ,p_cpp_qpp_exempt_flag            =>  p_cpp_qpp_exempt_flag
      ,p_fed_exempt_flag                =>  p_fed_exempt_flag
      ,p_ei_exempt_flag                 =>  p_ei_exempt_flag
      ,p_tax_calc_method                =>  p_tax_calc_method
      ,p_fed_override_amount            =>  l_fed_override_amount
      ,p_fed_override_rate              =>  l_fed_override_rate
      ,p_ca_tax_information_category    =>  p_ca_tax_information_category
      ,p_ca_tax_information1            =>  p_ca_tax_information1
      ,p_ca_tax_information2            =>  p_ca_tax_information2
      ,p_ca_tax_information3            =>  p_ca_tax_information3
      ,p_ca_tax_information4            =>  p_ca_tax_information4
      ,p_ca_tax_information5            =>  p_ca_tax_information5
      ,p_ca_tax_information6            =>  p_ca_tax_information6
      ,p_ca_tax_information7            =>  p_ca_tax_information7
      ,p_ca_tax_information8            =>  p_ca_tax_information8
      ,p_ca_tax_information9            =>  p_ca_tax_information9
      ,p_ca_tax_information10           =>  p_ca_tax_information10
      ,p_ca_tax_information11           =>  p_ca_tax_information11
      ,p_ca_tax_information12           =>  p_ca_tax_information12
      ,p_ca_tax_information13           =>  p_ca_tax_information13
      ,p_ca_tax_information14           =>  p_ca_tax_information14
      ,p_ca_tax_information15           =>  p_ca_tax_information15
      ,p_ca_tax_information16           =>  p_ca_tax_information16
      ,p_ca_tax_information17           =>  p_ca_tax_information17
      ,p_ca_tax_information18           =>  p_ca_tax_information18
      ,p_ca_tax_information19           =>  p_ca_tax_information19
      ,p_ca_tax_information20           =>  p_ca_tax_information20
      ,p_ca_tax_information21           =>  p_ca_tax_information21
      ,p_ca_tax_information22           =>  p_ca_tax_information22
      ,p_ca_tax_information23           =>  p_ca_tax_information23
      ,p_ca_tax_information24           =>  p_ca_tax_information24
      ,p_ca_tax_information25           =>  p_ca_tax_information25
      ,p_ca_tax_information26           =>  p_ca_tax_information26
      ,p_ca_tax_information27           =>  p_ca_tax_information27
      ,p_ca_tax_information28           =>  p_ca_tax_information28
      ,p_ca_tax_information29           =>  p_ca_tax_information29
      ,p_ca_tax_information30           =>  p_ca_tax_information30
      ,p_fed_lsf_amount                =>  l_fed_lsf_amount
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_ca_emp_fedtax_inf'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_ca_emp_fedtax_inf
    --
  end;
*/
  --

hr_utility.trace('call rowhandler');
  pay_cft_ins.ins
    (
     p_emp_fed_tax_inf_id            => l_emp_fed_tax_inf_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_legislation_code              => p_legislation_code
    ,p_assignment_id                 => p_assignment_id
    ,p_business_group_id             => p_business_group_id
    ,p_employment_province           => p_employment_province
    ,p_tax_credit_amount             => p_tax_credit_amount
    ,p_claim_code                    => p_claim_code
    ,p_basic_exemption_flag          => p_basic_exemption_flag
    ,p_additional_tax                => p_additional_tax
    ,p_annual_dedn                   => p_annual_dedn
    ,p_total_expense_by_commission   => p_total_expense_by_commission
    ,p_total_remnrtn_by_commission   => p_total_remnrtn_by_commission
    ,p_prescribed_zone_dedn_amt      => p_prescribed_zone_dedn_amt
    ,p_other_fedtax_credits          => p_other_fedtax_credits
    ,p_cpp_qpp_exempt_flag           => p_cpp_qpp_exempt_flag
    ,p_fed_exempt_flag               => p_fed_exempt_flag
    ,p_ei_exempt_flag                => p_ei_exempt_flag
    ,p_tax_calc_method               => p_tax_calc_method
    ,p_fed_override_amount           => p_fed_override_amount
    ,p_fed_override_rate             => p_fed_override_rate
    ,p_ca_tax_information_category   => p_ca_tax_information_category
    ,p_ca_tax_information1           => p_ca_tax_information1
    ,p_ca_tax_information2           => p_ca_tax_information2
    ,p_ca_tax_information3           => p_ca_tax_information3
    ,p_ca_tax_information4           => p_ca_tax_information4
    ,p_ca_tax_information5           => p_ca_tax_information5
    ,p_ca_tax_information6           => p_ca_tax_information6
    ,p_ca_tax_information7           => p_ca_tax_information7
    ,p_ca_tax_information8           => p_ca_tax_information8
    ,p_ca_tax_information9           => p_ca_tax_information9
    ,p_ca_tax_information10          => p_ca_tax_information10
    ,p_ca_tax_information11          => p_ca_tax_information11
    ,p_ca_tax_information12          => p_ca_tax_information12
    ,p_ca_tax_information13          => p_ca_tax_information13
    ,p_ca_tax_information14          => p_ca_tax_information14
    ,p_ca_tax_information15          => p_ca_tax_information15
    ,p_ca_tax_information16          => p_ca_tax_information16
    ,p_ca_tax_information17          => p_ca_tax_information17
    ,p_ca_tax_information18          => p_ca_tax_information18
    ,p_ca_tax_information19          => p_ca_tax_information19
    ,p_ca_tax_information20          => p_ca_tax_information20
    ,p_ca_tax_information21          => p_ca_tax_information21
    ,p_ca_tax_information22          => p_ca_tax_information22
    ,p_ca_tax_information23          => p_ca_tax_information23
    ,p_ca_tax_information24          => p_ca_tax_information24
    ,p_ca_tax_information25          => p_ca_tax_information25
    ,p_ca_tax_information26          => p_ca_tax_information26
    ,p_ca_tax_information27          => p_ca_tax_information27
    ,p_ca_tax_information28          => p_ca_tax_information28
    ,p_ca_tax_information29          => p_ca_tax_information29
    ,p_ca_tax_information30          => p_ca_tax_information30
    ,p_object_version_number         => l_object_version_number
    ,p_fed_lsf_amount               =>  p_fed_lsf_amount
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
/*
  begin
    --
    -- Start of API User Hook for the after hook of create_ca_emp_fedtax_inf
    --
    pay_ca_emp_fedtax_inf_bk1.create_ca_emp_fedtax_inf_a
      (
       p_emp_fed_tax_inf_id             =>  l_emp_fed_tax_inf_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_legislation_code               =>  p_legislation_code
      ,p_assignment_id                  =>  p_assignment_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_employment_province            =>  p_employment_province
      ,p_tax_credit_amount              =>  p_tax_credit_amount
      ,p_claim_code                     =>  p_claim_code
      ,p_basic_exemption_flag           =>  p_basic_exemption_flag
      ,p_additional_tax                 =>  p_additional_tax
      ,p_annual_dedn                    =>  p_annual_dedn
      ,p_total_expense_by_commission    =>  p_total_expense_by_commission
      ,p_total_remnrtn_by_commission    =>  p_total_remnrtn_by_commission
      ,p_prescribed_zone_dedn_amt       =>  p_prescribed_zone_dedn_amt
      ,p_other_fedtax_credits           =>  p_other_fedtax_credits
      ,p_cpp_qpp_exempt_flag            =>  p_cpp_qpp_exempt_flag
      ,p_fed_exempt_flag                =>  p_fed_exempt_flag
      ,p_ei_exempt_flag                 =>  p_ei_exempt_flag
      ,p_tax_calc_method                =>  p_tax_calc_method
      ,p_fed_override_amount            =>  p_fed_override_amount
      ,p_fed_override_rate              =>  p_fed_override_rate
      ,p_ca_tax_information_category    =>  p_ca_tax_information_category
      ,p_ca_tax_information1            =>  p_ca_tax_information1
      ,p_ca_tax_information2            =>  p_ca_tax_information2
      ,p_ca_tax_information3            =>  p_ca_tax_information3
      ,p_ca_tax_information4            =>  p_ca_tax_information4
      ,p_ca_tax_information5            =>  p_ca_tax_information5
      ,p_ca_tax_information6            =>  p_ca_tax_information6
      ,p_ca_tax_information7            =>  p_ca_tax_information7
      ,p_ca_tax_information8            =>  p_ca_tax_information8
      ,p_ca_tax_information9            =>  p_ca_tax_information9
      ,p_ca_tax_information10           =>  p_ca_tax_information10
      ,p_ca_tax_information11           =>  p_ca_tax_information11
      ,p_ca_tax_information12           =>  p_ca_tax_information12
      ,p_ca_tax_information13           =>  p_ca_tax_information13
      ,p_ca_tax_information14           =>  p_ca_tax_information14
      ,p_ca_tax_information15           =>  p_ca_tax_information15
      ,p_ca_tax_information16           =>  p_ca_tax_information16
      ,p_ca_tax_information17           =>  p_ca_tax_information17
      ,p_ca_tax_information18           =>  p_ca_tax_information18
      ,p_ca_tax_information19           =>  p_ca_tax_information19
      ,p_ca_tax_information20           =>  p_ca_tax_information20
      ,p_ca_tax_information21           =>  p_ca_tax_information21
      ,p_ca_tax_information22           =>  p_ca_tax_information22
      ,p_ca_tax_information23           =>  p_ca_tax_information23
      ,p_ca_tax_information24           =>  p_ca_tax_information24
      ,p_ca_tax_information25           =>  p_ca_tax_information25
      ,p_ca_tax_information26           =>  p_ca_tax_information26
      ,p_ca_tax_information27           =>  p_ca_tax_information27
      ,p_ca_tax_information28           =>  p_ca_tax_information28
      ,p_ca_tax_information29           =>  p_ca_tax_information29
      ,p_ca_tax_information30           =>  p_ca_tax_information30
      ,p_object_version_number          =>  l_object_version_number
      ,p_fed_lsf_amount                =>  p_fed_lsf_amount
      ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_ca_emp_fedtax_inf'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_ca_emp_fedtax_inf
    --
  end;
*/
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
  p_emp_fed_tax_inf_id := l_emp_fed_tax_inf_id;
  p_effective_start_date := l_effective_start_date;
  p_effective_end_date := l_effective_end_date;
  p_object_version_number := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end if;
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_ca_emp_fedtax_inf;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_emp_fed_tax_inf_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
hr_utility.trace('In exeception');
    ROLLBACK TO create_ca_emp_fedtax_inf;
    raise;
    --
end create_ca_emp_fedtax_inf;
-- ----------------------------------------------------------------------------
-- |------------------------< update_ca_emp_fedtax_inf >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_ca_emp_fedtax_inf
  (p_validate                       in  boolean   default false
  ,p_emp_fed_tax_inf_id             in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_legislation_code               in  varchar2  default hr_api.g_varchar2
  ,p_assignment_id                  in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_employment_province            in  varchar2  default hr_api.g_varchar2
  ,p_tax_credit_amount              in  number    default hr_api.g_number
  ,p_claim_code                     in  varchar2  default hr_api.g_varchar2
  ,p_basic_exemption_flag           in  varchar2  default hr_api.g_varchar2
  ,p_additional_tax                 in  number    default hr_api.g_number
  ,p_annual_dedn                    in  number    default hr_api.g_number
  ,p_total_expense_by_commission    in  number    default hr_api.g_number
  ,p_total_remnrtn_by_commission    in  number    default hr_api.g_number
  ,p_prescribed_zone_dedn_amt       in  number    default hr_api.g_number
  ,p_other_fedtax_credits           in  varchar2  default hr_api.g_varchar2
  ,p_cpp_qpp_exempt_flag            in  varchar2  default hr_api.g_varchar2
  ,p_fed_exempt_flag                in  varchar2  default hr_api.g_varchar2
  ,p_ei_exempt_flag                 in  varchar2  default hr_api.g_varchar2
  ,p_tax_calc_method                in  varchar2  default hr_api.g_varchar2
  ,p_fed_override_amount            in  number    default hr_api.g_number
  ,p_fed_override_rate              in  number    default hr_api.g_number
  ,p_ca_tax_information_category    in  varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information1            in  varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information2            in  varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information3            in  varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information4            in  varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information5            in  varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information6            in  varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information7            in  varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information8            in  varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information9            in  varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information10           in  varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information11           in  varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information12           in  varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information13           in  varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information14           in  varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information15           in  varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information16           in  varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information17           in  varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information18           in  varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information19           in  varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information20           in  varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information21           in  varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information22           in  varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information23           in  varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information24           in  varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information25           in  varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information26           in  varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information27           in  varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information28           in  varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information29           in  varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information30           in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_fed_lsf_amount                in  number    default hr_api.g_number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_ca_emp_fedtax_inf';
  l_object_version_number pay_ca_emp_fed_tax_info_f.object_version_number%TYPE;
  l_effective_start_date pay_ca_emp_fed_tax_info_f.effective_start_date%TYPE;
  l_effective_end_date pay_ca_emp_fed_tax_info_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_ca_emp_fedtax_inf;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
/*
  begin
    --
    -- Start of API User Hook for the before hook of update_ca_emp_fedtax_inf
    --
    pay_ca_emp_fedtax_inf_bk2.update_ca_emp_fedtax_inf_b
      (
       p_emp_fed_tax_inf_id             =>  p_emp_fed_tax_inf_id
      ,p_legislation_code               =>  p_legislation_code
      ,p_assignment_id                  =>  p_assignment_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_employment_province            =>  p_employment_province
      ,p_tax_credit_amount              =>  p_tax_credit_amount
      ,p_claim_code                     =>  p_claim_code
      ,p_basic_exemption_flag           =>  p_basic_exemption_flag
      ,p_additional_tax                 =>  p_additional_tax
      ,p_annual_dedn                    =>  p_annual_dedn
      ,p_total_expense_by_commission    =>  p_total_expense_by_commission
      ,p_total_remnrtn_by_commission    =>  p_total_remnrtn_by_commission
      ,p_prescribed_zone_dedn_amt       =>  p_prescribed_zone_dedn_amt
      ,p_other_fedtax_credits           =>  p_other_fedtax_credits
      ,p_cpp_qpp_exempt_flag            =>  p_cpp_qpp_exempt_flag
      ,p_fed_exempt_flag                =>  p_fed_exempt_flag
      ,p_ei_exempt_flag                 =>  p_ei_exempt_flag
      ,p_tax_calc_method                =>  p_tax_calc_method
      ,p_fed_override_amount            =>  p_fed_override_amount
      ,p_fed_override_rate              =>  p_fed_override_rate
      ,p_ca_tax_information_category    =>  p_ca_tax_information_category
      ,p_ca_tax_information1            =>  p_ca_tax_information1
      ,p_ca_tax_information2            =>  p_ca_tax_information2
      ,p_ca_tax_information3            =>  p_ca_tax_information3
      ,p_ca_tax_information4            =>  p_ca_tax_information4
      ,p_ca_tax_information5            =>  p_ca_tax_information5
      ,p_ca_tax_information6            =>  p_ca_tax_information6
      ,p_ca_tax_information7            =>  p_ca_tax_information7
      ,p_ca_tax_information8            =>  p_ca_tax_information8
      ,p_ca_tax_information9            =>  p_ca_tax_information9
      ,p_ca_tax_information10           =>  p_ca_tax_information10
      ,p_ca_tax_information11           =>  p_ca_tax_information11
      ,p_ca_tax_information12           =>  p_ca_tax_information12
      ,p_ca_tax_information13           =>  p_ca_tax_information13
      ,p_ca_tax_information14           =>  p_ca_tax_information14
      ,p_ca_tax_information15           =>  p_ca_tax_information15
      ,p_ca_tax_information16           =>  p_ca_tax_information16
      ,p_ca_tax_information17           =>  p_ca_tax_information17
      ,p_ca_tax_information18           =>  p_ca_tax_information18
      ,p_ca_tax_information19           =>  p_ca_tax_information19
      ,p_ca_tax_information20           =>  p_ca_tax_information20
      ,p_ca_tax_information21           =>  p_ca_tax_information21
      ,p_ca_tax_information22           =>  p_ca_tax_information22
      ,p_ca_tax_information23           =>  p_ca_tax_information23
      ,p_ca_tax_information24           =>  p_ca_tax_information24
      ,p_ca_tax_information25           =>  p_ca_tax_information25
      ,p_ca_tax_information26           =>  p_ca_tax_information26
      ,p_ca_tax_information27           =>  p_ca_tax_information27
      ,p_ca_tax_information28           =>  p_ca_tax_information28
      ,p_ca_tax_information29           =>  p_ca_tax_information29
      ,p_ca_tax_information30           =>  p_ca_tax_information30
      ,p_object_version_number          =>  p_object_version_number
      ,p_fed_lsf_amount                =>  p_fed_lsf_amount
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_ca_emp_fedtax_inf'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_ca_emp_fedtax_inf
    --
  end;
  --
*/
  pay_cft_upd.upd
    (
     p_emp_fed_tax_inf_id            => p_emp_fed_tax_inf_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_legislation_code              => p_legislation_code
    ,p_assignment_id                 => p_assignment_id
    ,p_business_group_id             => p_business_group_id
    ,p_employment_province           => p_employment_province
    ,p_tax_credit_amount             => p_tax_credit_amount
    ,p_claim_code                    => p_claim_code
    ,p_basic_exemption_flag          => p_basic_exemption_flag
    ,p_additional_tax                => p_additional_tax
    ,p_annual_dedn                   => p_annual_dedn
    ,p_total_expense_by_commission   => p_total_expense_by_commission
    ,p_total_remnrtn_by_commission   => p_total_remnrtn_by_commission
    ,p_prescribed_zone_dedn_amt      => p_prescribed_zone_dedn_amt
    ,p_other_fedtax_credits          => p_other_fedtax_credits
    ,p_cpp_qpp_exempt_flag           => p_cpp_qpp_exempt_flag
    ,p_fed_exempt_flag               => p_fed_exempt_flag
    ,p_ei_exempt_flag                => p_ei_exempt_flag
    ,p_tax_calc_method               => p_tax_calc_method
    ,p_fed_override_amount           => p_fed_override_amount
    ,p_fed_override_rate             => p_fed_override_rate
    ,p_ca_tax_information_category   => p_ca_tax_information_category
    ,p_ca_tax_information1           => p_ca_tax_information1
    ,p_ca_tax_information2           => p_ca_tax_information2
    ,p_ca_tax_information3           => p_ca_tax_information3
    ,p_ca_tax_information4           => p_ca_tax_information4
    ,p_ca_tax_information5           => p_ca_tax_information5
    ,p_ca_tax_information6           => p_ca_tax_information6
    ,p_ca_tax_information7           => p_ca_tax_information7
    ,p_ca_tax_information8           => p_ca_tax_information8
    ,p_ca_tax_information9           => p_ca_tax_information9
    ,p_ca_tax_information10          => p_ca_tax_information10
    ,p_ca_tax_information11          => p_ca_tax_information11
    ,p_ca_tax_information12          => p_ca_tax_information12
    ,p_ca_tax_information13          => p_ca_tax_information13
    ,p_ca_tax_information14          => p_ca_tax_information14
    ,p_ca_tax_information15          => p_ca_tax_information15
    ,p_ca_tax_information16          => p_ca_tax_information16
    ,p_ca_tax_information17          => p_ca_tax_information17
    ,p_ca_tax_information18          => p_ca_tax_information18
    ,p_ca_tax_information19          => p_ca_tax_information19
    ,p_ca_tax_information20          => p_ca_tax_information20
    ,p_ca_tax_information21          => p_ca_tax_information21
    ,p_ca_tax_information22          => p_ca_tax_information22
    ,p_ca_tax_information23          => p_ca_tax_information23
    ,p_ca_tax_information24          => p_ca_tax_information24
    ,p_ca_tax_information25          => p_ca_tax_information25
    ,p_ca_tax_information26          => p_ca_tax_information26
    ,p_ca_tax_information27          => p_ca_tax_information27
    ,p_ca_tax_information28          => p_ca_tax_information28
    ,p_ca_tax_information29          => p_ca_tax_information29
    ,p_ca_tax_information30          => p_ca_tax_information30
    ,p_object_version_number         => l_object_version_number
    ,p_fed_lsf_amount                =>  p_fed_lsf_amount
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
/*
  begin
    --
    -- Start of API User Hook for the after hook of update_ca_emp_fedtax_inf
    --
    pay_ca_emp_fedtax_inf_bk2.update_ca_emp_fedtax_inf_a
      (
       p_emp_fed_tax_inf_id             =>  p_emp_fed_tax_inf_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_legislation_code               =>  p_legislation_code
      ,p_assignment_id                  =>  p_assignment_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_employment_province            =>  p_employment_province
      ,p_tax_credit_amount              =>  p_tax_credit_amount
      ,p_claim_code                     =>  p_claim_code
      ,p_basic_exemption_flag           =>  p_basic_exemption_flag
      ,p_additional_tax                 =>  p_additional_tax
      ,p_annual_dedn                    =>  p_annual_dedn
      ,p_total_expense_by_commission    =>  p_total_expense_by_commission
      ,p_total_remnrtn_by_commission    =>  p_total_remnrtn_by_commission
      ,p_prescribed_zone_dedn_amt       =>  p_prescribed_zone_dedn_amt
      ,p_other_fedtax_credits           =>  p_other_fedtax_credits
      ,p_cpp_qpp_exempt_flag            =>  p_cpp_qpp_exempt_flag
      ,p_fed_exempt_flag                =>  p_fed_exempt_flag
      ,p_ei_exempt_flag                 =>  p_ei_exempt_flag
      ,p_tax_calc_method                =>  p_tax_calc_method
      ,p_fed_override_amount            =>  p_fed_override_amount
      ,p_fed_override_rate              =>  p_fed_override_rate
      ,p_ca_tax_information_category    =>  p_ca_tax_information_category
      ,p_ca_tax_information1            =>  p_ca_tax_information1
      ,p_ca_tax_information2            =>  p_ca_tax_information2
      ,p_ca_tax_information3            =>  p_ca_tax_information3
      ,p_ca_tax_information4            =>  p_ca_tax_information4
      ,p_ca_tax_information5            =>  p_ca_tax_information5
      ,p_ca_tax_information6            =>  p_ca_tax_information6
      ,p_ca_tax_information7            =>  p_ca_tax_information7
      ,p_ca_tax_information8            =>  p_ca_tax_information8
      ,p_ca_tax_information9            =>  p_ca_tax_information9
      ,p_ca_tax_information10           =>  p_ca_tax_information10
      ,p_ca_tax_information11           =>  p_ca_tax_information11
      ,p_ca_tax_information12           =>  p_ca_tax_information12
      ,p_ca_tax_information13           =>  p_ca_tax_information13
      ,p_ca_tax_information14           =>  p_ca_tax_information14
      ,p_ca_tax_information15           =>  p_ca_tax_information15
      ,p_ca_tax_information16           =>  p_ca_tax_information16
      ,p_ca_tax_information17           =>  p_ca_tax_information17
      ,p_ca_tax_information18           =>  p_ca_tax_information18
      ,p_ca_tax_information19           =>  p_ca_tax_information19
      ,p_ca_tax_information20           =>  p_ca_tax_information20
      ,p_ca_tax_information21           =>  p_ca_tax_information21
      ,p_ca_tax_information22           =>  p_ca_tax_information22
      ,p_ca_tax_information23           =>  p_ca_tax_information23
      ,p_ca_tax_information24           =>  p_ca_tax_information24
      ,p_ca_tax_information25           =>  p_ca_tax_information25
      ,p_ca_tax_information26           =>  p_ca_tax_information26
      ,p_ca_tax_information27           =>  p_ca_tax_information27
      ,p_ca_tax_information28           =>  p_ca_tax_information28
      ,p_ca_tax_information29           =>  p_ca_tax_information29
      ,p_ca_tax_information30           =>  p_ca_tax_information30
      ,p_object_version_number          =>  l_object_version_number
      ,p_fed_lsf_amount                =>  p_fed_lsf_amount
      ,p_effective_date                     => trunc(p_effective_date)
      ,p_datetrack_mode                     => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_ca_emp_fedtax_inf'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_ca_emp_fedtax_inf
    --
  end;
*/
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
    ROLLBACK TO update_ca_emp_fedtax_inf;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO update_ca_emp_fedtax_inf;
    raise;
    --
end update_ca_emp_fedtax_inf;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_ca_emp_fedtax_inf >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ca_emp_fedtax_inf
  (p_validate                       in  boolean  default false
  ,p_emp_fed_tax_inf_id             in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_ca_emp_fedtax_inf';
  l_object_version_number pay_ca_emp_fed_tax_info_f.object_version_number%TYPE;
  l_effective_start_date pay_ca_emp_fed_tax_info_f.effective_start_date%TYPE;
  l_effective_end_date pay_ca_emp_fed_tax_info_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_ca_emp_fedtax_inf;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  --
/*
  begin
    --
    -- Start of API User Hook for the before hook of delete_ca_emp_fedtax_inf
    --
    pay_ca_emp_fedtax_inf_bk3.delete_ca_emp_fedtax_inf_b
      (
       p_emp_fed_tax_inf_id             =>  p_emp_fed_tax_inf_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_ca_emp_fedtax_inf'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_ca_emp_fedtax_inf
    --
  end;
*/
  --
  pay_cft_del.del
    (
     p_emp_fed_tax_inf_id            => p_emp_fed_tax_inf_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
/*
  begin
    --
    -- Start of API User Hook for the after hook of delete_ca_emp_fedtax_inf
    --
    pay_ca_emp_fedtax_inf_bk3.delete_ca_emp_fedtax_inf_a
      (
       p_emp_fed_tax_inf_id             =>  p_emp_fed_tax_inf_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_ca_emp_fedtax_inf'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_ca_emp_fedtax_inf
    --
  end;
*/
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
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
    ROLLBACK TO delete_ca_emp_fedtax_inf;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_effective_start_date := null;
    p_effective_end_date := null;
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO delete_ca_emp_fedtax_inf;
    raise;
    --
end delete_ca_emp_fedtax_inf;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
  p_emp_fed_tax_inf_id                   in     number
  ,p_object_version_number          in     number
  ,p_effective_date                 in     date
  ,p_datetrack_mode                 in     varchar2
  ,p_validation_start_date          out  nocopy   date
  ,p_validation_end_date            out  nocopy   date
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
  pay_cft_shd.lck
    (
     p_emp_fed_tax_inf_id         => p_emp_fed_tax_inf_id
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
/** Business Processes added manually */

procedure pull_tax_records( p_assignment_id   in number,
                            p_new_start_date  in date,
                            p_default_date    in date) is
       l_ef_date DATE;
       l_proc VARCHAR2(50) := 'pay_ca_emp_fedtax_inf_api.pull_tax_records';

begin
       hr_utility.set_location('Entering: ' || l_proc, 5);

       if p_new_start_date < p_default_date then
                l_ef_date := p_default_date;
       elsif p_new_start_date > p_default_date then
                l_ef_date := p_new_start_date;
       else -- do nothing
          return;
       end if;

       /* First update the tax rules records */

  update PAY_CA_EMP_FED_TAX_INFO_F
       set    effective_start_date = p_new_start_date
       where  assignment_id = p_assignment_id
       and    l_ef_date between effective_start_date and effective_end_date;

       if sql%notfound then
          hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
          hr_utility.set_message_token('PROCEDURE',l_proc);
          hr_utility.set_message_token('STEP','2');
          hr_utility.raise_error;
       end if;

 /* Next delete any orphaned rows */
       if p_new_start_date > p_default_date then
               hr_utility.set_location(l_proc, 10);
               delete PAY_CA_EMP_FED_TAX_INFO_F
               where  assignment_id = p_assignment_id
               and    p_new_start_date >  effective_start_date;


        end if;

       hr_utility.set_location('Leaving: ' || l_proc, 20);

end pull_tax_records;

procedure check_hiring_date( p_assignment_id   in number,
                             p_default_date    in date,
                             p_s_start_date    in date) is

begin

    /* If the hiring date has been changed and pulled back, for the
       assignment then pull back the start date of the tax rules records
    */

    if p_s_start_date < p_default_date then
       pull_tax_records(p_assignment_id     => p_assignment_id,
                        p_new_start_date    => p_s_start_date,
                        p_default_date      => p_default_date);


    /* If the hiring date has been pulled forward then the person api
       pulls forward the element entries but does not pull forward the
       tax rules record. So, we will pull them forward */

    elsif p_s_start_date > p_default_date then

       pull_tax_records(p_assignment_id     => p_assignment_id,
                        p_new_start_date    => p_s_start_date,
                        p_default_date      => p_default_date);
    end if;

end check_hiring_date;

procedure tax_record_already_present(p_assignment_id in number,
                                     p_effective_date in date,
                                     p_rec_present out nocopy varchar2) is
cursor csr_chk_assignment_rec is
       select  '1'
       from   pay_ca_emp_fed_tax_info_f   paf
       where  paf.assignment_id         = p_assignment_id;
/*
       and    p_effective_date between paf.effective_start_date and
                                     paf.effective_end_date ;
*/
cursor csr_get_default_date (p_assignment number) is
         select min(effective_start_date)
           from   pay_ca_emp_fed_tax_info_f   fti
             where  fti.assignment_id         = p_assignment_id;

l_present varchar2(2);
l_default_date date;
rec_present varchar2(1);
begin
open csr_chk_assignment_rec;
fetch csr_chk_assignment_rec into l_present;
if csr_chk_assignment_rec%FOUND then
       p_rec_present := 'Y';
          /* Get the default date */
          open csr_get_default_date(p_assignment_id);

             fetch csr_get_default_date into l_default_date;

               if l_default_date is null then

             close csr_get_default_date;
             hr_utility.set_message(801 , 'HR_6153_ALL_PROCEDURE_FAIL');
             hr_utility.set_message_token('PROCEDURE',
             'pay_ca_emp_fedtax_inf_api.tax_record_already_present');
             hr_utility.set_message_token('STEP','1');
             hr_utility.raise_error;

          end if;

         close csr_get_default_date;

         /* Now check for pull back of the hiring date */
                   check_hiring_date(p_assignment_id  => p_assignment_id,
                                     p_default_date   => l_default_date,
                                     p_s_start_date   => p_effective_date);


else
 p_rec_present := 'N';
end if;
end tax_record_already_present;
/* ends tax_record_already_present */

procedure perform_assignment_validation(p_assignment_id in varchar2,
                                     p_effective_date in date)
is
l_location_id number;
l_country varchar2(30);
cursor csr_chk_assignment is
       select  paf.location_id
       from   PER_ASSIGNMENTS_F   paf
       where  paf.assignment_id         = p_assignment_id
       and    p_effective_date between paf.effective_start_date and
                                     paf.effective_end_date ;
cursor csr_get_location(p_location_id number) is
   select hrl.country from hr_locations hrl
   where hrl.location_id = p_location_id;

begin
/* Check whether the assignment is present as of that date or not and
the location id of it. Raise error message if assignment is not present
or location_id is null */
open csr_chk_assignment;
fetch csr_chk_assignment into l_location_id;

  if csr_chk_assignment%NOTFOUND then
               hr_utility.set_message(800 , 'HR_74004_ASSIGNMENT_ABSENT');
               hr_utility.raise_error;
  else
   if l_location_id is NULL then
               hr_utility.set_message(800, 'HR_74005_LOCATION_ABSENT');
               hr_utility.raise_error;
   else
    open csr_get_location(l_location_id);
    fetch csr_get_location into l_country;
    if l_country is null or l_country <> 'CA' then
               hr_utility.set_message(800, 'HR_74006_LOCATION_WRONG');
               hr_utility.raise_error;
    end if;
   end if;
  end if;
end perform_assignment_validation;

/******* end perform validation ***/

procedure check_basic_exemption(p_basic_exemption_flag in varchar2,
                                p_tax_credit_amount in number) is
begin
if p_basic_exemption_flag = 'Y'  then
 if p_tax_credit_amount is not null then
               hr_utility.set_message(800, 'HR_74007_BOTH_NOT_NULL');
               hr_utility.raise_error;
 end if;
elsif p_basic_exemption_flag = 'N' then
 if p_tax_credit_amount is NULL then
               hr_utility.set_message(800, 'HR_74008_BOTH_NULL');
               hr_utility.raise_error;
 end if;
elsif p_basic_exemption_flag is NULL then
 if p_tax_credit_amount is NULL then
               hr_utility.set_message(800, 'HR_74008_BOTH_NULL');
               hr_utility.raise_error;
 end if;
end if;
end check_basic_exemption;


procedure check_employment_province(p_employment_province in varchar2) is

cursor csr_employment_province is
select '1' from hr_lookups lkp
where lkp.lookup_code = p_employment_province
and   lkp.lookup_type = 'CA_PROVINCE';

l_employment_province varchar2(30);

begin
open csr_employment_province;
fetch csr_employment_province into l_employment_province;
if  csr_employment_province%NOTFOUND then
               hr_utility.set_message(800, 'HR_74009_EMPL_PROV_WRONG');
               hr_utility.raise_error;
end if;
end check_employment_province;

function convert_null_to_zero(p_value in number) return number is
begin
 if p_value is null then
  return 0;
 else
  return p_value;
 end if;
end convert_null_to_zero;

/** End business processes **/
end pay_ca_emp_fedtax_inf_api;

/
