--------------------------------------------------------
--  DDL for Package Body PAY_CA_EMP_PRVTAX_INF_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CA_EMP_PRVTAX_INF_API" as
/* $Header: pycprapi.pkb 120.2.12000000.1 2007/01/17 18:11:39 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  pay_ca_emp_prvtax_inf_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_ca_emp_prvtax_inf >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_ca_emp_prvtax_inf
  (p_validate                       in  boolean   default false
  ,p_emp_province_tax_inf_id        out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_legislation_code               in  varchar2
  ,p_assignment_id                  in  number
  ,p_business_group_id              in  number
  ,p_province_code                  in  varchar2
  ,p_jurisdiction_code              in  varchar2  default null
  ,p_tax_credit_amount              in  number    default null
  ,p_basic_exemption_flag           in  varchar2  default null
  ,p_deduction_code                 in  varchar2  default null
  ,p_extra_info_not_provided        in  varchar2  default null
  ,p_marriage_status                in  varchar2  default null
  ,p_no_of_infirm_dependants        in  number    default null
  ,p_non_resident_status            in  varchar2  default null
  ,p_disability_status              in  varchar2  default null
  ,p_no_of_dependants               in  number    default null
  ,p_annual_dedn                    in  number    default null
  ,p_total_expense_by_commission    in  number    default null
  ,p_total_remnrtn_by_commission    in  number    default null
  ,p_prescribed_zone_dedn_amt       in  number    default null
  ,p_additional_tax                 in  number    default null
  ,p_prov_override_rate             in  number    default null
  ,p_prov_override_amount           in  number    default null
  ,p_prov_exempt_flag               in  varchar2  default null
  ,p_pmed_exempt_flag               in  varchar2  default null
  ,p_wc_exempt_flag                 in  varchar2  default null
  ,p_qpp_exempt_flag                in  varchar2  default null
  ,p_tax_calc_method                in  varchar2  default null
  ,p_other_tax_credit               in  number    default null
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
  ,p_prov_lsp_amount                in  number    default null
  ,p_effective_date                 in  date
  ,p_ppip_exempt_flag               in  varchar2  default null
  ) is
  --
  -- Declare cursors and local variables
  --
  l_emp_province_tax_inf_id pay_ca_emp_prov_tax_info_f.emp_province_tax_inf_id%TYPE;
  l_effective_start_date pay_ca_emp_prov_tax_info_f.effective_start_date%TYPE;
  l_effective_end_date pay_ca_emp_prov_tax_info_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_ca_emp_prvtax_inf';
  l_object_version_number pay_ca_emp_prov_tax_info_f.object_version_number%TYPE;
  l_rec_present varchar2(1);
  l_tax_credit_amount   number;
  l_additional_tax   number;
  l_annual_dedn     number;
  l_total_expense_by_commission    number;
  l_total_remnrtn_by_commission   number;
  l_prescribed_zone_dedn_amt   number;
  l_other_tax_credit      number;
  l_prov_override_amount      number;
  l_prov_override_rate        number;
  l_no_of_dependants          number;
  l_no_of_infirm_dependants   number;
  l_prov_lsp_amount   number;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_ca_emp_prvtax_inf;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --

  perform_assignment_validation(p_assignment_id => p_assignment_id,
                                p_effective_date => p_effective_date);
--
 tax_record_already_present(p_assignment_id => p_assignment_id,
                            p_province_code => p_province_code,
                            p_effective_date => p_effective_date,
                            p_rec_present    => l_rec_present) ; /* added */

if l_rec_present <> 'Y' then

/* Defaulting all the number fields which are null */

 l_tax_credit_amount := convert_null_to_zero(p_tax_credit_amount);
 l_additional_tax := convert_null_to_zero(p_additional_tax);
 l_annual_dedn    := convert_null_to_zero(p_annual_dedn);
 l_total_expense_by_commission  := convert_null_to_zero(p_total_expense_by_commission);
 l_total_remnrtn_by_commission  := convert_null_to_zero(p_total_remnrtn_by_commission);
 l_prescribed_zone_dedn_amt := convert_null_to_zero(p_prescribed_zone_dedn_amt);
 l_other_tax_credit    := convert_null_to_zero(p_other_tax_credit);
 l_prov_override_amount    := convert_null_to_zero(p_prov_override_amount);
 l_prov_override_rate    := convert_null_to_zero(p_prov_override_rate);
 l_no_of_dependants    := convert_null_to_zero(p_no_of_dependants);
 l_no_of_infirm_dependants   := convert_null_to_zero(p_no_of_infirm_dependants);
 l_prov_lsp_amount := convert_null_to_zero(p_prov_lsp_amount);
/*
  begin
    --
    -- Start of API User Hook for the before hook of create_ca_emp_prvtax_inf
    --
    pay_ca_emp_prvtax_inf_bk1.create_ca_emp_prvtax_inf_b
      (
       p_legislation_code               =>  p_legislation_code
      ,p_assignment_id                  =>  p_assignment_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_province_code                  =>  p_province_code
      ,p_jurisdiction_code              =>  p_jurisdiction_code
      ,p_tax_credit_amount              =>  p_tax_credit_amount
      ,p_basic_exemption_flag           =>  p_basic_exemption_flag
      ,p_deduction_code                 =>  p_deduction_code
      ,p_extra_info_not_provided        =>  p_extra_info_not_provided
      ,p_marriage_status                =>  p_marriage_status
      ,p_no_of_infirm_dependants        =>  p_no_of_infirm_dependants
      ,p_non_resident_status            =>  p_non_resident_status
      ,p_disability_status              =>  p_disability_status
      ,p_no_of_dependants               =>  p_no_of_dependants
      ,p_annual_dedn                    =>  p_annual_dedn
      ,p_total_expense_by_commission    =>  p_total_expense_by_commission
      ,p_total_remnrtn_by_commission    =>  p_total_remnrtn_by_commission
      ,p_prescribed_zone_dedn_amt       =>  p_prescribed_zone_dedn_amt
      ,p_additional_tax                 =>  p_additional_tax
      ,p_prov_override_rate             =>  p_prov_override_rate
      ,p_prov_override_amount           =>  p_prov_override_amount
      ,p_prov_exempt_flag               =>  p_prov_exempt_flag
      ,p_pmed_exempt_flag               =>  p_pmed_exempt_flag
      ,p_wc_exempt_flag                 =>  p_wc_exempt_flag
      ,p_qpp_exempt_flag                =>  p_qpp_exempt_flag
      ,p_tax_calc_method                =>  p_tax_calc_method
      ,p_other_tax_credit               =>  p_other_tax_credit
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
      ,p_prov_lsp_amount                =>  p_prov_lsp_amount
      ,p_effective_date                 => trunc(p_effective_date)
      ,p_ppip_exempt_flag               => p_ppip_exempt_flag
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_ca_emp_prvtax_inf'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_ca_emp_prvtax_inf
    --
  end;
*/
  --
  pay_cpt_ins.ins
    (
     p_emp_province_tax_inf_id       => l_emp_province_tax_inf_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_legislation_code              => p_legislation_code
    ,p_assignment_id                 => p_assignment_id
    ,p_business_group_id             => p_business_group_id
    ,p_province_code                 => p_province_code
    ,p_jurisdiction_code             => p_jurisdiction_code
    ,p_tax_credit_amount             => p_tax_credit_amount
    ,p_basic_exemption_flag          => p_basic_exemption_flag
    ,p_deduction_code                => p_deduction_code
    ,p_extra_info_not_provided       => p_extra_info_not_provided
    ,p_marriage_status               => p_marriage_status
    ,p_no_of_infirm_dependants       => l_no_of_infirm_dependants
    ,p_non_resident_status           => p_non_resident_status
    ,p_disability_status             => p_disability_status
    ,p_no_of_dependants              => l_no_of_dependants
    ,p_annual_dedn                   => l_annual_dedn
    ,p_total_expense_by_commission   => l_total_expense_by_commission
    ,p_total_remnrtn_by_commission   => l_total_remnrtn_by_commission
    ,p_prescribed_zone_dedn_amt      => l_prescribed_zone_dedn_amt
    ,p_additional_tax                => l_additional_tax
    ,p_prov_override_rate            => l_prov_override_rate
    ,p_prov_override_amount          => l_prov_override_amount
    ,p_prov_exempt_flag              => p_prov_exempt_flag
    ,p_pmed_exempt_flag              => p_pmed_exempt_flag
    ,p_wc_exempt_flag                => p_wc_exempt_flag
    ,p_qpp_exempt_flag               => p_qpp_exempt_flag
    ,p_tax_calc_method               => p_tax_calc_method
    ,p_other_tax_credit              => l_other_tax_credit
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
    ,p_prov_lsp_amount               =>  l_prov_lsp_amount
    ,p_effective_date                => trunc(p_effective_date)
    ,p_ppip_exempt_flag               => p_ppip_exempt_flag
    );
  --
/*
  begin
    --
    -- Start of API User Hook for the after hook of create_ca_emp_prvtax_inf
    --

    pay_ca_emp_prvtax_inf_bk1.create_ca_emp_prvtax_inf_a
      (
       p_emp_province_tax_inf_id        =>  l_emp_province_tax_inf_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_legislation_code               =>  p_legislation_code
      ,p_assignment_id                  =>  p_assignment_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_province_code                  =>  p_province_code
      ,p_jurisdiction_code              =>  p_jurisdiction_code
      ,p_tax_credit_amount              =>  p_tax_credit_amount
      ,p_basic_exemption_flag           =>  p_basic_exemption_flag
      ,p_deduction_code                 =>  p_deduction_code
      ,p_extra_info_not_provided        =>  p_extra_info_not_provided
      ,p_marriage_status                =>  p_marriage_status
      ,p_no_of_infirm_dependants        =>  p_no_of_infirm_dependants
      ,p_non_resident_status            =>  p_non_resident_status
      ,p_disability_status              =>  p_disability_status
      ,p_no_of_dependants               =>  p_no_of_dependants
      ,p_annual_dedn                    =>  p_annual_dedn
      ,p_total_expense_by_commission    =>  p_total_expense_by_commission
      ,p_total_remnrtn_by_commission    =>  p_total_remnrtn_by_commission
      ,p_prescribed_zone_dedn_amt       =>  p_prescribed_zone_dedn_amt
      ,p_additional_tax                 =>  p_additional_tax
      ,p_prov_override_rate             =>  p_prov_override_rate
      ,p_prov_override_amount           =>  p_prov_override_amount
      ,p_prov_exempt_flag               =>  p_prov_exempt_flag
      ,p_pmed_exempt_flag               =>  p_pmed_exempt_flag
      ,p_wc_exempt_flag                 =>  p_wc_exempt_flag
      ,p_qpp_exempt_flag                =>  p_qpp_exempt_flag
      ,p_tax_calc_method                =>  p_tax_calc_method
      ,p_other_tax_credit               =>  p_other_tax_credit
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
      ,p_prov_lsp_amount               =>  p_prov_lsp_amount
      ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_ca_emp_prvtax_inf'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_ca_emp_prvtax_inf
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
  p_emp_province_tax_inf_id := l_emp_province_tax_inf_id;
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
    ROLLBACK TO create_ca_emp_prvtax_inf;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_emp_province_tax_inf_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_ca_emp_prvtax_inf;
    --
    -- Reset IN OUT params and set OUT params.
    --
    p_emp_province_tax_inf_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    --
    raise;
    --
end create_ca_emp_prvtax_inf;
-- ----------------------------------------------------------------------------
-- |------------------------< update_ca_emp_prvtax_inf >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_ca_emp_prvtax_inf
  (p_validate                       in  boolean   default false
  ,p_emp_province_tax_inf_id        in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_legislation_code               in  varchar2  default hr_api.g_varchar2
  ,p_assignment_id                  in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_province_code                  in  varchar2  default hr_api.g_varchar2
  ,p_jurisdiction_code              in  varchar2  default hr_api.g_varchar2
  ,p_tax_credit_amount              in  number    default hr_api.g_number
  ,p_basic_exemption_flag           in  varchar2  default hr_api.g_varchar2
  ,p_deduction_code                 in  varchar2  default hr_api.g_varchar2
  ,p_extra_info_not_provided        in  varchar2  default hr_api.g_varchar2
  ,p_marriage_status                in  varchar2  default hr_api.g_varchar2
  ,p_no_of_infirm_dependants        in  number    default hr_api.g_number
  ,p_non_resident_status            in  varchar2  default hr_api.g_varchar2
  ,p_disability_status              in  varchar2  default hr_api.g_varchar2
  ,p_no_of_dependants               in  number    default hr_api.g_number
  ,p_annual_dedn                    in  number    default hr_api.g_number
  ,p_total_expense_by_commission    in  number    default hr_api.g_number
  ,p_total_remnrtn_by_commission    in  number    default hr_api.g_number
  ,p_prescribed_zone_dedn_amt       in  number    default hr_api.g_number
  ,p_additional_tax                 in  number    default hr_api.g_number
  ,p_prov_override_rate             in  number    default hr_api.g_number
  ,p_prov_override_amount           in  number    default hr_api.g_number
  ,p_prov_exempt_flag               in  varchar2  default hr_api.g_varchar2
  ,p_pmed_exempt_flag               in  varchar2  default hr_api.g_varchar2
  ,p_wc_exempt_flag                 in  varchar2  default hr_api.g_varchar2
  ,p_qpp_exempt_flag                in  varchar2  default hr_api.g_varchar2
  ,p_tax_calc_method                in  varchar2  default hr_api.g_varchar2
  ,p_other_tax_credit               in  number    default hr_api.g_number
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
  ,p_prov_lsp_amount                in  number    default hr_api.g_number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ,p_ppip_exempt_flag                in  varchar2  default hr_api.g_varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_ca_emp_prvtax_inf';
  l_object_version_number pay_ca_emp_prov_tax_info_f.object_version_number%TYPE;
  l_effective_start_date pay_ca_emp_prov_tax_info_f.effective_start_date%TYPE;
  l_effective_end_date pay_ca_emp_prov_tax_info_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_ca_emp_prvtax_inf;
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
    -- Start of API User Hook for the before hook of update_ca_emp_prvtax_inf
    --
    pay_ca_emp_prvtax_inf_bk2.update_ca_emp_prvtax_inf_b
      (
       p_emp_province_tax_inf_id        =>  p_emp_province_tax_inf_id
      ,p_legislation_code               =>  p_legislation_code
      ,p_assignment_id                  =>  p_assignment_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_province_code                  =>  p_province_code
      ,p_jurisdiction_code              =>  p_jurisdiction_code
      ,p_tax_credit_amount              =>  p_tax_credit_amount
      ,p_basic_exemption_flag           =>  p_basic_exemption_flag
      ,p_deduction_code                 =>  p_deduction_code
      ,p_extra_info_not_provided        =>  p_extra_info_not_provided
      ,p_marriage_status                =>  p_marriage_status
      ,p_no_of_infirm_dependants        =>  p_no_of_infirm_dependants
      ,p_non_resident_status            =>  p_non_resident_status
      ,p_disability_status              =>  p_disability_status
      ,p_no_of_dependants               =>  p_no_of_dependants
      ,p_annual_dedn                    =>  p_annual_dedn
      ,p_total_expense_by_commission    =>  p_total_expense_by_commission
      ,p_total_remnrtn_by_commission    =>  p_total_remnrtn_by_commission
      ,p_prescribed_zone_dedn_amt       =>  p_prescribed_zone_dedn_amt
      ,p_additional_tax                 =>  p_additional_tax
      ,p_prov_override_rate             =>  p_prov_override_rate
      ,p_prov_override_amount           =>  p_prov_override_amount
      ,p_prov_exempt_flag               =>  p_prov_exempt_flag
      ,p_pmed_exempt_flag               =>  p_pmed_exempt_flag
      ,p_wc_exempt_flag                 =>  p_wc_exempt_flag
      ,p_qpp_exempt_flag                =>  p_qpp_exempt_flag
      ,p_tax_calc_method                =>  p_tax_calc_method
      ,p_other_tax_credit               =>  p_other_tax_credit
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
      ,p_prov_lsp_amount               =>  p_prov_lsp_amount
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_ca_emp_prvtax_inf'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_ca_emp_prvtax_inf
    --
  end;
*/
  --

  pay_cpt_upd.upd
    (
     p_emp_province_tax_inf_id       => p_emp_province_tax_inf_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_legislation_code              => p_legislation_code
    ,p_assignment_id                 => p_assignment_id
    ,p_business_group_id             => p_business_group_id
    ,p_province_code                 => p_province_code
    ,p_jurisdiction_code             => p_jurisdiction_code
    ,p_tax_credit_amount             => p_tax_credit_amount
    ,p_basic_exemption_flag          => p_basic_exemption_flag
    ,p_deduction_code                => p_deduction_code
    ,p_extra_info_not_provided       => p_extra_info_not_provided
    ,p_marriage_status               => p_marriage_status
    ,p_no_of_infirm_dependants       => p_no_of_infirm_dependants
    ,p_non_resident_status           => p_non_resident_status
    ,p_disability_status             => p_disability_status
    ,p_no_of_dependants              => p_no_of_dependants
    ,p_annual_dedn                   => p_annual_dedn
    ,p_total_expense_by_commission   => p_total_expense_by_commission
    ,p_total_remnrtn_by_commission   => p_total_remnrtn_by_commission
    ,p_prescribed_zone_dedn_amt      => p_prescribed_zone_dedn_amt
    ,p_additional_tax                => p_additional_tax
    ,p_prov_override_rate            => p_prov_override_rate
    ,p_prov_override_amount          => p_prov_override_amount
    ,p_prov_exempt_flag              => p_prov_exempt_flag
    ,p_pmed_exempt_flag              => p_pmed_exempt_flag
    ,p_wc_exempt_flag                => p_wc_exempt_flag
    ,p_qpp_exempt_flag               => p_qpp_exempt_flag
    ,p_tax_calc_method               => p_tax_calc_method
    ,p_other_tax_credit              => p_other_tax_credit
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
    ,p_prov_lsp_amount               =>  p_prov_lsp_amount
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode
    ,p_ppip_exempt_flag               => p_ppip_exempt_flag
    );
  --
/*
  begin
    --
    -- Start of API User Hook for the after hook of update_ca_emp_prvtax_inf
    --
    pay_ca_emp_prvtax_inf_bk2.update_ca_emp_prvtax_inf_a
      (
       p_emp_province_tax_inf_id        =>  p_emp_province_tax_inf_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_legislation_code               =>  p_legislation_code
      ,p_assignment_id                  =>  p_assignment_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_province_code                  =>  p_province_code
      ,p_jurisdiction_code              =>  p_jurisdiction_code
      ,p_tax_credit_amount              =>  p_tax_credit_amount
      ,p_basic_exemption_flag           =>  p_basic_exemption_flag
      ,p_deduction_code                 =>  p_deduction_code
      ,p_extra_info_not_provided        =>  p_extra_info_not_provided
      ,p_marriage_status                =>  p_marriage_status
      ,p_no_of_infirm_dependants        =>  p_no_of_infirm_dependants
      ,p_non_resident_status            =>  p_non_resident_status
      ,p_disability_status              =>  p_disability_status
      ,p_no_of_dependants               =>  p_no_of_dependants
      ,p_annual_dedn                    =>  p_annual_dedn
      ,p_total_expense_by_commission    =>  p_total_expense_by_commission
      ,p_total_remnrtn_by_commission    =>  p_total_remnrtn_by_commission
      ,p_prescribed_zone_dedn_amt       =>  p_prescribed_zone_dedn_amt
      ,p_additional_tax                 =>  p_additional_tax
      ,p_prov_override_rate             =>  p_prov_override_rate
      ,p_prov_override_amount           =>  p_prov_override_amount
      ,p_prov_exempt_flag               =>  p_prov_exempt_flag
      ,p_pmed_exempt_flag               =>  p_pmed_exempt_flag
      ,p_wc_exempt_flag                 =>  p_wc_exempt_flag
      ,p_qpp_exempt_flag                =>  p_qpp_exempt_flag
      ,p_tax_calc_method                =>  p_tax_calc_method
      ,p_other_tax_credit               =>  p_other_tax_credit
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
      ,p_prov_lsp_amount               =>  p_prov_lsp_amount
      ,p_effective_date                     => trunc(p_effective_date)
      ,p_datetrack_mode                     => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_ca_emp_prvtax_inf'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_ca_emp_prvtax_inf
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
    ROLLBACK TO update_ca_emp_prvtax_inf;
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
    ROLLBACK TO update_ca_emp_prvtax_inf;
    --
    -- Reset IN OUT params and set OUT params.
    --
    p_effective_start_date := null;
    p_effective_end_date   := null;
    p_object_version_number := l_object_version_number;
    --
    raise;
    --
end update_ca_emp_prvtax_inf;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_ca_emp_prvtax_inf >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ca_emp_prvtax_inf
  (p_validate                       in  boolean  default false
  ,p_emp_province_tax_inf_id        in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_ca_emp_prvtax_inf';
  l_object_version_number pay_ca_emp_prov_tax_info_f.object_version_number%TYPE;
  l_effective_start_date pay_ca_emp_prov_tax_info_f.effective_start_date%TYPE;
  l_effective_end_date pay_ca_emp_prov_tax_info_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_ca_emp_prvtax_inf;
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
    -- Start of API User Hook for the before hook of delete_ca_emp_prvtax_inf
    --
    pay_ca_emp_prvtax_inf_bk3.delete_ca_emp_prvtax_inf_b
      (
       p_emp_province_tax_inf_id        =>  p_emp_province_tax_inf_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_ca_emp_prvtax_inf'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_ca_emp_prvtax_inf
    --
  end;
  --
*/
  pay_cpt_del.del
    (
     p_emp_province_tax_inf_id       => p_emp_province_tax_inf_id
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
    -- Start of API User Hook for the after hook of delete_ca_emp_prvtax_inf
    --
    pay_ca_emp_prvtax_inf_bk3.delete_ca_emp_prvtax_inf_a
      (
       p_emp_province_tax_inf_id        =>  p_emp_province_tax_inf_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_ca_emp_prvtax_inf'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_ca_emp_prvtax_inf
    --
  end;
  --
*/
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
    ROLLBACK TO delete_ca_emp_prvtax_inf;
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
    ROLLBACK TO delete_ca_emp_prvtax_inf;
    --
    -- Reset IN OUT params and set OUT params.
    --
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number         := l_object_version_number;
    --
    raise;
    --
end delete_ca_emp_prvtax_inf;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_emp_province_tax_inf_id                   in     number
  ,p_object_version_number          in     number
  ,p_effective_date                 in     date
  ,p_datetrack_mode                 in     varchar2
  ,p_validation_start_date          out    nocopy date
  ,p_validation_end_date            out    nocopy date
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
  pay_cpt_shd.lck
    (
      p_emp_province_tax_inf_id                 => p_emp_province_tax_inf_id
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

/** Business Processes added **/
procedure pull_tax_records( p_assignment_id   in number,
                            p_new_start_date  in date,
                            p_default_date    in date,
                            p_province_code   in varchar2) is
       l_ef_date DATE;
       l_proc VARCHAR2(50) := 'pay_ca_emp_provtax_inf_api.pull_tax_records';

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

  update PAY_CA_EMP_PROV_TAX_INFO_F
       set    effective_start_date = p_new_start_date
     where  assignment_id = p_assignment_id
       and    l_ef_date between effective_start_date and effective_end_date
       and  province_code = p_province_code;

       if sql%notfound then
          hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
          hr_utility.set_message_token('PROCEDURE',l_proc);
          hr_utility.set_message_token('STEP','2');
          hr_utility.raise_error;
       end if;

 /* Next delete any orphaned rows */
       if p_new_start_date > p_default_date then
               hr_utility.set_location(l_proc, 10);
               delete PAY_CA_EMP_PROV_TAX_INFO_F
               where  assignment_id = p_assignment_id
               and    p_new_start_date >  effective_start_date
               and province_code = p_province_code;

        end if;

       hr_utility.set_location('Leaving: ' || l_proc, 20);

end pull_tax_records;

procedure check_hiring_date( p_assignment_id   in number,
                             p_default_date    in date,
                             p_s_start_date    in date,
                             p_prov_code       in varchar2) is

begin

    /* If the hiring date has been changed and pulled back, for the
       assignment then pull back the start date of the tax rules records
    */

    if p_s_start_date < p_default_date then
       pull_tax_records(p_assignment_id     => p_assignment_id,
                        p_new_start_date    => p_s_start_date,
                        p_default_date      => p_default_date,
                        p_province_code     => p_prov_code);


    /* If the hiring date has been pulled forward then the person api
       pulls forward the element entries but does not pull forward the
       tax rules record. So, we will pull them forward */

  elsif p_s_start_date > p_default_date then

       pull_tax_records(p_assignment_id     => p_assignment_id,
                        p_new_start_date    => p_s_start_date,
                        p_default_date      => p_default_date,
                        p_province_code     => p_prov_code);
    end if;

end check_hiring_date;

procedure tax_record_already_present(p_assignment_id in number,
                                     p_province_code in varchar2,
                                     p_effective_date in date,
                                     p_rec_present out nocopy varchar2) is
cursor csr_chk_assignment_rec is
       select  '1'
       from   pay_ca_emp_prov_tax_info_f   ptt
       where  ptt.assignment_id         = p_assignment_id
/*
       and    p_effective_date between ptt.effective_start_date and
                                     ptt.effective_end_date
*/
       and    ptt.province_code = p_province_code;

cursor csr_get_default_date (p_assignment number,p_province varchar2) is
         select min(effective_start_date)
           from   pay_ca_emp_prov_tax_info_f   ptt
             where    ptt.assignment_id         = p_assignment_id
               and    ptt.province_code = p_province_code;


l_present varchar2(2);
l_default_date date;
rec_present varchar2(1);
begin
  open csr_chk_assignment_rec;
    fetch csr_chk_assignment_rec into l_present;
      if csr_chk_assignment_rec%FOUND then
         p_rec_present := 'Y';
           /* Get the default date */
          open csr_get_default_date(p_assignment_id,p_province_code);

             fetch csr_get_default_date into l_default_date;

               if l_default_date is null then

                  close csr_get_default_date;
                  hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
                  hr_utility.set_message_token('PROCEDURE',
                  'pay_ca_emp_fedtax_inf_api.tax_record_already_present');
                  hr_utility.set_message_token('STEP','1');
                  hr_utility.raise_error;

               end if;

          close csr_get_default_date;

                   /* Now check for pull back of the hiring date */
                   check_hiring_date(p_assignment_id  => p_assignment_id,
                                     p_default_date   => l_default_date,
                                     p_s_start_date   => p_effective_date,
                                     p_prov_code      => p_province_code);
      else
         p_rec_present := 'N';
      end if;
end tax_record_already_present;

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
/* Check whether the assignment is present as of that date or not and the location id of it. Raise error message if assignment is not present or location_id is null */
open csr_chk_assignment;
fetch csr_chk_assignment into l_location_id;

  if csr_chk_assignment%NOTFOUND then
               hr_utility.set_message(800, 'HR_74004_ASSIGNMENT_ABSENT');
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

procedure check_province_code(p_province_code in varchar2) is

cursor csr_province_code is
select '1' from hr_lookups lkp
where lkp.lookup_code = p_province_code
and   lkp.lookup_type = 'CA_PROVINCE';

l_province_code varchar2(30);

begin
open csr_province_code;
fetch csr_province_code into l_province_code;
if  csr_province_code%NOTFOUND then
               hr_utility.set_message(800, 'HR_74009_EMPL_PROV_WRONG');
               hr_utility.raise_error;
end if;
end check_province_code;
--
function convert_null_to_zero(p_value in number) return number is
begin
 if p_value is null then
  return 0;
 else
  return p_value;
 end if;
end convert_null_to_zero;
--
end pay_ca_emp_prvtax_inf_api;

/
