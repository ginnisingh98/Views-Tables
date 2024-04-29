--------------------------------------------------------
--  DDL for Package Body PQP_ALIEN_TRANS_DATA_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_ALIEN_TRANS_DATA_API" as
/* $Header: pqatdapi.pkb 115.6 2003/01/22 00:54:14 tmehra ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  pqp_alien_trans_data_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_alien_trans_data >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_alien_trans_data
  (p_validate                       in  boolean   default false
  ,p_alien_transaction_id           out nocopy number
  ,p_person_id                      in  number    default null
  ,p_data_source_type               in  varchar2  default null
  ,p_tax_year                       in  number    default null
  ,p_income_code                    in  varchar2  default null
  ,p_withholding_rate               in  number    default null
  ,p_income_code_sub_type           in  varchar2  default null
  ,p_exemption_code                 in  varchar2  default null
  ,p_maximum_benefit_amount         in  number    default null
  ,p_retro_lose_ben_amt_flag        in  varchar2  default null
  ,p_date_benefit_ends              in  date      default null
  ,p_retro_lose_ben_date_flag       in  varchar2  default null
  ,p_current_residency_status       in  varchar2  default null
  ,p_nra_to_ra_date                 in  date      default null
  ,p_target_departure_date          in  date      default null
  ,p_tax_residence_country_code     in  varchar2  default null
  ,p_treaty_info_update_date        in  date      default null
  ,p_nra_exempt_from_fica           in  varchar2  default null
  ,p_student_exempt_from_fica       in  varchar2  default null
  ,p_addl_withholding_flag          in  varchar2  default null
  ,p_addl_withholding_amt           in  number    default null
  ,p_addl_wthldng_amt_period_type   in  varchar2  default null
  ,p_personal_exemption             in  number    default null
  ,p_addl_exemption_allowed         in  number    default null
  ,p_number_of_days_in_usa          in  number    default null
  ,p_wthldg_allow_eligible_flag     in  varchar2  default null
  ,p_treaty_ben_allowed_flag        in  varchar2  default null
  ,p_treaty_benefits_start_date     in  date      default null
  ,p_ra_effective_date              in  date      default null
  ,p_state_code                     in  varchar2  default null
  ,p_state_honors_treaty_flag       in  varchar2  default null
  ,p_ytd_payments                   in  number    default null
  ,p_ytd_w2_payments                in  number    default null
  ,p_ytd_w2_withholding             in  number    default null
  ,p_ytd_withholding_allowance      in  number    default null
  ,p_ytd_treaty_payments            in  number    default null
  ,p_ytd_treaty_withheld_amt        in  number    default null
  ,p_record_source                  in  varchar2  default null
  ,p_visa_type                      in  varchar2  default null
  ,p_j_sub_type                     in  varchar2  default null
  ,p_primary_activity               in  varchar2  default null
  ,p_non_us_country_code            in  varchar2  default null
  ,p_citizenship_country_code       in  varchar2  default null
  ,p_constant_addl_tax              in  number    default null
  ,p_date_8233_signed               in  date      default null
  ,p_date_w4_signed                 in  date      default null
  ,p_error_indicator                in  varchar2  default null
  ,p_prev_er_treaty_benefit_amt     in  number    default null
  ,p_error_text                     in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ,p_current_analysis               in  varchar2  default null
  ,p_forecast_income_code           in  varchar2  default null
  ) is
  --
  -- Declare cursors and local variables
  --
  l_alien_transaction_id pqp_alien_transaction_data.alien_transaction_id%TYPE;
  l_proc varchar2(72) := g_package||'create_alien_trans_data';
  l_object_version_number pqp_alien_transaction_data.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_alien_trans_data;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_alien_trans_data
    --
    pqp_alien_trans_data_bk1.create_alien_trans_data_b
      (
       p_person_id                      =>  p_person_id
      ,p_data_source_type               =>  p_data_source_type
      ,p_tax_year                       =>  p_tax_year
      ,p_income_code                    =>  p_income_code
      ,p_withholding_rate               =>  p_withholding_rate
      ,p_income_code_sub_type           =>  p_income_code_sub_type
      ,p_exemption_code                 =>  p_exemption_code
      ,p_maximum_benefit_amount         =>  p_maximum_benefit_amount
      ,p_retro_lose_ben_amt_flag        =>  p_retro_lose_ben_amt_flag
      ,p_date_benefit_ends              =>  p_date_benefit_ends
      ,p_retro_lose_ben_date_flag       =>  p_retro_lose_ben_date_flag
      ,p_current_residency_status       =>  p_current_residency_status
      ,p_nra_to_ra_date                 =>  p_nra_to_ra_date
      ,p_target_departure_date          =>  p_target_departure_date
      ,p_tax_residence_country_code     =>  p_tax_residence_country_code
      ,p_treaty_info_update_date        =>  p_treaty_info_update_date
      ,p_nra_exempt_from_fica           =>  p_nra_exempt_from_fica
      ,p_student_exempt_from_fica       =>  p_student_exempt_from_fica
      ,p_addl_withholding_flag          =>  p_addl_withholding_flag
      ,p_addl_withholding_amt           =>  p_addl_withholding_amt
      ,p_addl_wthldng_amt_period_type   =>  p_addl_wthldng_amt_period_type
      ,p_personal_exemption             =>  p_personal_exemption
      ,p_addl_exemption_allowed         =>  p_addl_exemption_allowed
      ,p_number_of_days_in_usa          =>  p_number_of_days_in_usa
      ,p_wthldg_allow_eligible_flag     =>  p_wthldg_allow_eligible_flag
      ,p_treaty_ben_allowed_flag        =>  p_treaty_ben_allowed_flag
      ,p_treaty_benefits_start_date     =>  p_treaty_benefits_start_date
      ,p_ra_effective_date              =>  p_ra_effective_date
      ,p_state_code                     =>  p_state_code
      ,p_state_honors_treaty_flag       =>  p_state_honors_treaty_flag
      ,p_ytd_payments                   =>  p_ytd_payments
      ,p_ytd_w2_payments                =>  p_ytd_w2_payments
      ,p_ytd_w2_withholding             =>  p_ytd_w2_withholding
      ,p_ytd_withholding_allowance      =>  p_ytd_withholding_allowance
      ,p_ytd_treaty_payments            =>  p_ytd_treaty_payments
      ,p_ytd_treaty_withheld_amt        =>  p_ytd_treaty_withheld_amt
      ,p_record_source                  =>  p_record_source
      ,p_visa_type                      =>  p_visa_type
      ,p_j_sub_type                     =>  p_j_sub_type
      ,p_primary_activity               =>  p_primary_activity
      ,p_non_us_country_code            =>  p_non_us_country_code
      ,p_citizenship_country_code       =>  p_citizenship_country_code
      ,p_constant_addl_tax              =>  p_constant_addl_tax
      ,p_date_8233_signed               =>  p_date_8233_signed
      ,p_date_w4_signed                 =>  p_date_w4_signed
      ,p_error_indicator                =>  p_error_indicator
      ,p_prev_er_treaty_benefit_amt     =>  p_prev_er_treaty_benefit_amt
      ,p_error_text                     =>  p_error_text
      ,p_effective_date                 =>  trunc(p_effective_date)
      ,p_current_analysis               =>  p_current_analysis
      ,p_forecast_income_code           =>  p_forecast_income_code
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_ALIEN_TRANS_DATA'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_alien_trans_data
    --
  end;
  --
  pqp_atd_ins.ins
    (
     p_alien_transaction_id          => l_alien_transaction_id
    ,p_person_id                     => p_person_id
    ,p_data_source_type              => p_data_source_type
    ,p_tax_year                      => p_tax_year
    ,p_income_code                   => p_income_code
    ,p_withholding_rate              => p_withholding_rate
    ,p_income_code_sub_type          => p_income_code_sub_type
    ,p_exemption_code                => p_exemption_code
    ,p_maximum_benefit_amount        => p_maximum_benefit_amount
    ,p_retro_lose_ben_amt_flag       => p_retro_lose_ben_amt_flag
    ,p_date_benefit_ends             => p_date_benefit_ends
    ,p_retro_lose_ben_date_flag      => p_retro_lose_ben_date_flag
    ,p_current_residency_status      => p_current_residency_status
    ,p_nra_to_ra_date                => p_nra_to_ra_date
    ,p_target_departure_date         => p_target_departure_date
    ,p_tax_residence_country_code    => p_tax_residence_country_code
    ,p_treaty_info_update_date       => p_treaty_info_update_date
    ,p_nra_exempt_from_fica          => p_nra_exempt_from_fica
    ,p_student_exempt_from_fica      => p_student_exempt_from_fica
    ,p_addl_withholding_flag         => p_addl_withholding_flag
    ,p_addl_withholding_amt          => p_addl_withholding_amt
    ,p_addl_wthldng_amt_period_type  => p_addl_wthldng_amt_period_type
    ,p_personal_exemption            => p_personal_exemption
    ,p_addl_exemption_allowed        => p_addl_exemption_allowed
    ,p_number_of_days_in_usa         => p_number_of_days_in_usa
    ,p_wthldg_allow_eligible_flag    => p_wthldg_allow_eligible_flag
    ,p_treaty_ben_allowed_flag       => p_treaty_ben_allowed_flag
    ,p_treaty_benefits_start_date    => p_treaty_benefits_start_date
    ,p_ra_effective_date             => p_ra_effective_date
    ,p_state_code                    => p_state_code
    ,p_state_honors_treaty_flag      => p_state_honors_treaty_flag
    ,p_ytd_payments                  => p_ytd_payments
    ,p_ytd_w2_payments               => p_ytd_w2_payments
    ,p_ytd_w2_withholding            => p_ytd_w2_withholding
    ,p_ytd_withholding_allowance     => p_ytd_withholding_allowance
    ,p_ytd_treaty_payments           => p_ytd_treaty_payments
    ,p_ytd_treaty_withheld_amt       => p_ytd_treaty_withheld_amt
    ,p_record_source                 => p_record_source
    ,p_visa_type                     => p_visa_type
    ,p_j_sub_type                    => p_j_sub_type
    ,p_primary_activity              => p_primary_activity
    ,p_non_us_country_code           => p_non_us_country_code
    ,p_citizenship_country_code      => p_citizenship_country_code
    ,p_constant_addl_tax             => p_constant_addl_tax
    ,p_date_8233_signed              => p_date_8233_signed
    ,p_date_w4_signed                => p_date_w4_signed
    ,p_error_indicator               => p_error_indicator
    ,p_prev_er_treaty_benefit_amt    => p_prev_er_treaty_benefit_amt
    ,p_error_text                    => p_error_text
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_current_analysis              =>  p_current_analysis
    ,p_forecast_income_code          =>  p_forecast_income_code
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_alien_trans_data
    --
    pqp_alien_trans_data_bk1.create_alien_trans_data_a
      (
       p_alien_transaction_id           =>  l_alien_transaction_id
      ,p_person_id                      =>  p_person_id
      ,p_data_source_type               =>  p_data_source_type
      ,p_tax_year                       =>  p_tax_year
      ,p_income_code                    =>  p_income_code
      ,p_withholding_rate               =>  p_withholding_rate
      ,p_income_code_sub_type           =>  p_income_code_sub_type
      ,p_exemption_code                 =>  p_exemption_code
      ,p_maximum_benefit_amount         =>  p_maximum_benefit_amount
      ,p_retro_lose_ben_amt_flag        =>  p_retro_lose_ben_amt_flag
      ,p_date_benefit_ends              =>  p_date_benefit_ends
      ,p_retro_lose_ben_date_flag       =>  p_retro_lose_ben_date_flag
      ,p_current_residency_status       =>  p_current_residency_status
      ,p_nra_to_ra_date                 =>  p_nra_to_ra_date
      ,p_target_departure_date          =>  p_target_departure_date
      ,p_tax_residence_country_code     =>  p_tax_residence_country_code
      ,p_treaty_info_update_date        =>  p_treaty_info_update_date
      ,p_nra_exempt_from_fica           =>  p_nra_exempt_from_fica
      ,p_student_exempt_from_fica       =>  p_student_exempt_from_fica
      ,p_addl_withholding_flag          =>  p_addl_withholding_flag
      ,p_addl_withholding_amt           =>  p_addl_withholding_amt
      ,p_addl_wthldng_amt_period_type   =>  p_addl_wthldng_amt_period_type
      ,p_personal_exemption             =>  p_personal_exemption
      ,p_addl_exemption_allowed         =>  p_addl_exemption_allowed
      ,p_number_of_days_in_usa          =>  p_number_of_days_in_usa
      ,p_wthldg_allow_eligible_flag     =>  p_wthldg_allow_eligible_flag
      ,p_treaty_ben_allowed_flag        =>  p_treaty_ben_allowed_flag
      ,p_treaty_benefits_start_date     =>  p_treaty_benefits_start_date
      ,p_ra_effective_date              =>  p_ra_effective_date
      ,p_state_code                     =>  p_state_code
      ,p_state_honors_treaty_flag       =>  p_state_honors_treaty_flag
      ,p_ytd_payments                   =>  p_ytd_payments
      ,p_ytd_w2_payments                =>  p_ytd_w2_payments
      ,p_ytd_w2_withholding             =>  p_ytd_w2_withholding
      ,p_ytd_withholding_allowance      =>  p_ytd_withholding_allowance
      ,p_ytd_treaty_payments            =>  p_ytd_treaty_payments
      ,p_ytd_treaty_withheld_amt        =>  p_ytd_treaty_withheld_amt
      ,p_record_source                  =>  p_record_source
      ,p_visa_type                      =>  p_visa_type
      ,p_j_sub_type                     =>  p_j_sub_type
      ,p_primary_activity               =>  p_primary_activity
      ,p_non_us_country_code            =>  p_non_us_country_code
      ,p_citizenship_country_code       =>  p_citizenship_country_code
      ,p_constant_addl_tax              =>  p_constant_addl_tax
      ,p_date_8233_signed               =>  p_date_8233_signed
      ,p_date_w4_signed                 =>  p_date_w4_signed
      ,p_error_indicator                =>  p_error_indicator
      ,p_prev_er_treaty_benefit_amt     =>  p_prev_er_treaty_benefit_amt
      ,p_error_text                     =>  p_error_text
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
      ,p_current_analysis              =>  p_current_analysis
      ,p_forecast_income_code          =>  p_forecast_income_code
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_ALIEN_TRANS_DATA'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_alien_trans_data
    --
  end;
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
  p_alien_transaction_id := l_alien_transaction_id;
  p_object_version_number := l_object_version_number;
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
    ROLLBACK TO create_alien_trans_data;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_alien_transaction_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --

    ROLLBACK TO create_alien_trans_data;

    p_alien_transaction_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
    --
end create_alien_trans_data;
-- ----------------------------------------------------------------------------
-- |------------------------< update_alien_trans_data >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_alien_trans_data
  (p_validate                       in  boolean   default false
  ,p_alien_transaction_id           in  number
  ,p_person_id                      in  number    default hr_api.g_number
  ,p_data_source_type               in  varchar2  default hr_api.g_varchar2
  ,p_tax_year                       in  number    default hr_api.g_number
  ,p_income_code                    in  varchar2  default hr_api.g_varchar2
  ,p_withholding_rate               in  number    default hr_api.g_number
  ,p_income_code_sub_type           in  varchar2  default hr_api.g_varchar2
  ,p_exemption_code                 in  varchar2  default hr_api.g_varchar2
  ,p_maximum_benefit_amount         in  number    default hr_api.g_number
  ,p_retro_lose_ben_amt_flag        in  varchar2  default hr_api.g_varchar2
  ,p_date_benefit_ends              in  date      default hr_api.g_date
  ,p_retro_lose_ben_date_flag       in  varchar2  default hr_api.g_varchar2
  ,p_current_residency_status       in  varchar2  default hr_api.g_varchar2
  ,p_nra_to_ra_date                 in  date      default hr_api.g_date
  ,p_target_departure_date          in  date      default hr_api.g_date
  ,p_tax_residence_country_code     in  varchar2  default hr_api.g_varchar2
  ,p_treaty_info_update_date        in  date      default hr_api.g_date
  ,p_nra_exempt_from_fica           in  varchar2  default hr_api.g_varchar2
  ,p_student_exempt_from_fica       in  varchar2  default hr_api.g_varchar2
  ,p_addl_withholding_flag          in  varchar2  default hr_api.g_varchar2
  ,p_addl_withholding_amt           in  number    default hr_api.g_number
  ,p_addl_wthldng_amt_period_type   in  varchar2  default hr_api.g_varchar2
  ,p_personal_exemption             in  number    default hr_api.g_number
  ,p_addl_exemption_allowed         in  number    default hr_api.g_number
  ,p_number_of_days_in_usa          in  number    default hr_api.g_number
  ,p_wthldg_allow_eligible_flag     in  varchar2  default hr_api.g_varchar2
  ,p_treaty_ben_allowed_flag        in  varchar2  default hr_api.g_varchar2
  ,p_treaty_benefits_start_date     in  date      default hr_api.g_date
  ,p_ra_effective_date              in  date      default hr_api.g_date
  ,p_state_code                     in  varchar2  default hr_api.g_varchar2
  ,p_state_honors_treaty_flag       in  varchar2  default hr_api.g_varchar2
  ,p_ytd_payments                   in  number    default hr_api.g_number
  ,p_ytd_w2_payments                in  number    default hr_api.g_number
  ,p_ytd_w2_withholding             in  number    default hr_api.g_number
  ,p_ytd_withholding_allowance      in  number    default hr_api.g_number
  ,p_ytd_treaty_payments            in  number    default hr_api.g_number
  ,p_ytd_treaty_withheld_amt        in  number    default hr_api.g_number
  ,p_record_source                  in  varchar2  default hr_api.g_varchar2
  ,p_visa_type                      in  varchar2  default hr_api.g_varchar2
  ,p_j_sub_type                     in  varchar2  default hr_api.g_varchar2
  ,p_primary_activity               in  varchar2  default hr_api.g_varchar2
  ,p_non_us_country_code            in  varchar2  default hr_api.g_varchar2
  ,p_citizenship_country_code       in  varchar2  default hr_api.g_varchar2
  ,p_constant_addl_tax              in  number    default hr_api.g_number
  ,p_date_8233_signed               in  date      default hr_api.g_date
  ,p_date_w4_signed                 in  date      default hr_api.g_date
  ,p_error_indicator                in  varchar2  default hr_api.g_varchar2
  ,p_prev_er_treaty_benefit_amt     in  number    default hr_api.g_number
  ,p_error_text                     in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_current_analysis               in  varchar2  default hr_api.g_varchar2
  ,p_forecast_income_code           in  varchar2  default hr_api.g_varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_alien_trans_data';
  l_object_version_number pqp_alien_transaction_data.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_alien_trans_data;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_alien_trans_data
    --
    pqp_alien_trans_data_bk2.update_alien_trans_data_b
      (
       p_alien_transaction_id           =>  p_alien_transaction_id
      ,p_person_id                      =>  p_person_id
      ,p_data_source_type               =>  p_data_source_type
      ,p_tax_year                       =>  p_tax_year
      ,p_income_code                    =>  p_income_code
      ,p_withholding_rate               =>  p_withholding_rate
      ,p_income_code_sub_type           =>  p_income_code_sub_type
      ,p_exemption_code                 =>  p_exemption_code
      ,p_maximum_benefit_amount         =>  p_maximum_benefit_amount
      ,p_retro_lose_ben_amt_flag        =>  p_retro_lose_ben_amt_flag
      ,p_date_benefit_ends              =>  p_date_benefit_ends
      ,p_retro_lose_ben_date_flag       =>  p_retro_lose_ben_date_flag
      ,p_current_residency_status       =>  p_current_residency_status
      ,p_nra_to_ra_date                 =>  p_nra_to_ra_date
      ,p_target_departure_date          =>  p_target_departure_date
      ,p_tax_residence_country_code     =>  p_tax_residence_country_code
      ,p_treaty_info_update_date        =>  p_treaty_info_update_date
      ,p_nra_exempt_from_fica           =>  p_nra_exempt_from_fica
      ,p_student_exempt_from_fica       =>  p_student_exempt_from_fica
      ,p_addl_withholding_flag          =>  p_addl_withholding_flag
      ,p_addl_withholding_amt           =>  p_addl_withholding_amt
      ,p_addl_wthldng_amt_period_type   =>  p_addl_wthldng_amt_period_type
      ,p_personal_exemption             =>  p_personal_exemption
      ,p_addl_exemption_allowed         =>  p_addl_exemption_allowed
      ,p_number_of_days_in_usa          =>  p_number_of_days_in_usa
      ,p_wthldg_allow_eligible_flag     =>  p_wthldg_allow_eligible_flag
      ,p_treaty_ben_allowed_flag        =>  p_treaty_ben_allowed_flag
      ,p_treaty_benefits_start_date     =>  p_treaty_benefits_start_date
      ,p_ra_effective_date              =>  p_ra_effective_date
      ,p_state_code                     =>  p_state_code
      ,p_state_honors_treaty_flag       =>  p_state_honors_treaty_flag
      ,p_ytd_payments                   =>  p_ytd_payments
      ,p_ytd_w2_payments                =>  p_ytd_w2_payments
      ,p_ytd_w2_withholding             =>  p_ytd_w2_withholding
      ,p_ytd_withholding_allowance      =>  p_ytd_withholding_allowance
      ,p_ytd_treaty_payments            =>  p_ytd_treaty_payments
      ,p_ytd_treaty_withheld_amt        =>  p_ytd_treaty_withheld_amt
      ,p_record_source                  =>  p_record_source
      ,p_visa_type                      =>  p_visa_type
      ,p_j_sub_type                     =>  p_j_sub_type
      ,p_primary_activity               =>  p_primary_activity
      ,p_non_us_country_code            =>  p_non_us_country_code
      ,p_citizenship_country_code       =>  p_citizenship_country_code
      ,p_constant_addl_tax              =>  p_constant_addl_tax
      ,p_date_8233_signed               =>  p_date_8233_signed
      ,p_date_w4_signed                 =>  p_date_w4_signed
      ,p_error_indicator                =>  p_error_indicator
      ,p_prev_er_treaty_benefit_amt     =>  p_prev_er_treaty_benefit_amt
      ,p_error_text                     =>  p_error_text
      ,p_object_version_number          =>  p_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
      ,p_current_analysis              =>  p_current_analysis
      ,p_forecast_income_code          =>  p_forecast_income_code
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_ALIEN_TRANS_DATA'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_alien_trans_data
    --
  end;
  --
  pqp_atd_upd.upd
    (
     p_alien_transaction_id          => p_alien_transaction_id
    ,p_person_id                     => p_person_id
    ,p_data_source_type              => p_data_source_type
    ,p_tax_year                      => p_tax_year
    ,p_income_code                   => p_income_code
    ,p_withholding_rate              => p_withholding_rate
    ,p_income_code_sub_type          => p_income_code_sub_type
    ,p_exemption_code                => p_exemption_code
    ,p_maximum_benefit_amount        => p_maximum_benefit_amount
    ,p_retro_lose_ben_amt_flag       => p_retro_lose_ben_amt_flag
    ,p_date_benefit_ends             => p_date_benefit_ends
    ,p_retro_lose_ben_date_flag      => p_retro_lose_ben_date_flag
    ,p_current_residency_status      => p_current_residency_status
    ,p_nra_to_ra_date                => p_nra_to_ra_date
    ,p_target_departure_date         => p_target_departure_date
    ,p_tax_residence_country_code    => p_tax_residence_country_code
    ,p_treaty_info_update_date       => p_treaty_info_update_date
    ,p_nra_exempt_from_fica          => p_nra_exempt_from_fica
    ,p_student_exempt_from_fica      => p_student_exempt_from_fica
    ,p_addl_withholding_flag         => p_addl_withholding_flag
    ,p_addl_withholding_amt          => p_addl_withholding_amt
    ,p_addl_wthldng_amt_period_type  => p_addl_wthldng_amt_period_type
    ,p_personal_exemption            => p_personal_exemption
    ,p_addl_exemption_allowed        => p_addl_exemption_allowed
    ,p_number_of_days_in_usa         => p_number_of_days_in_usa
    ,p_wthldg_allow_eligible_flag    => p_wthldg_allow_eligible_flag
    ,p_treaty_ben_allowed_flag       => p_treaty_ben_allowed_flag
    ,p_treaty_benefits_start_date    => p_treaty_benefits_start_date
    ,p_ra_effective_date             => p_ra_effective_date
    ,p_state_code                    => p_state_code
    ,p_state_honors_treaty_flag      => p_state_honors_treaty_flag
    ,p_ytd_payments                  => p_ytd_payments
    ,p_ytd_w2_payments               => p_ytd_w2_payments
    ,p_ytd_w2_withholding            => p_ytd_w2_withholding
    ,p_ytd_withholding_allowance     => p_ytd_withholding_allowance
    ,p_ytd_treaty_payments           => p_ytd_treaty_payments
    ,p_ytd_treaty_withheld_amt       => p_ytd_treaty_withheld_amt
    ,p_record_source                 => p_record_source
    ,p_visa_type                     => p_visa_type
    ,p_j_sub_type                    => p_j_sub_type
    ,p_primary_activity              => p_primary_activity
    ,p_non_us_country_code           => p_non_us_country_code
    ,p_citizenship_country_code      => p_citizenship_country_code
    ,p_constant_addl_tax             => p_constant_addl_tax
    ,p_date_8233_signed              => p_date_8233_signed
    ,p_date_w4_signed                => p_date_w4_signed
    ,p_error_indicator               => p_error_indicator
    ,p_prev_er_treaty_benefit_amt    => p_prev_er_treaty_benefit_amt
    ,p_error_text                    => p_error_text
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_current_analysis              =>  p_current_analysis
    ,p_forecast_income_code          =>  p_forecast_income_code
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_alien_trans_data
    --
    pqp_alien_trans_data_bk2.update_alien_trans_data_a
      (
       p_alien_transaction_id           =>  p_alien_transaction_id
      ,p_person_id                      =>  p_person_id
      ,p_data_source_type               =>  p_data_source_type
      ,p_tax_year                       =>  p_tax_year
      ,p_income_code                    =>  p_income_code
      ,p_withholding_rate               =>  p_withholding_rate
      ,p_income_code_sub_type           =>  p_income_code_sub_type
      ,p_exemption_code                 =>  p_exemption_code
      ,p_maximum_benefit_amount         =>  p_maximum_benefit_amount
      ,p_retro_lose_ben_amt_flag        =>  p_retro_lose_ben_amt_flag
      ,p_date_benefit_ends              =>  p_date_benefit_ends
      ,p_retro_lose_ben_date_flag       =>  p_retro_lose_ben_date_flag
      ,p_current_residency_status       =>  p_current_residency_status
      ,p_nra_to_ra_date                 =>  p_nra_to_ra_date
      ,p_target_departure_date          =>  p_target_departure_date
      ,p_tax_residence_country_code     =>  p_tax_residence_country_code
      ,p_treaty_info_update_date        =>  p_treaty_info_update_date
      ,p_nra_exempt_from_fica           =>  p_nra_exempt_from_fica
      ,p_student_exempt_from_fica       =>  p_student_exempt_from_fica
      ,p_addl_withholding_flag          =>  p_addl_withholding_flag
      ,p_addl_withholding_amt           =>  p_addl_withholding_amt
      ,p_addl_wthldng_amt_period_type   =>  p_addl_wthldng_amt_period_type
      ,p_personal_exemption             =>  p_personal_exemption
      ,p_addl_exemption_allowed         =>  p_addl_exemption_allowed
      ,p_number_of_days_in_usa          =>  p_number_of_days_in_usa
      ,p_wthldg_allow_eligible_flag     =>  p_wthldg_allow_eligible_flag
      ,p_treaty_ben_allowed_flag        =>  p_treaty_ben_allowed_flag
      ,p_treaty_benefits_start_date     =>  p_treaty_benefits_start_date
      ,p_ra_effective_date              =>  p_ra_effective_date
      ,p_state_code                     =>  p_state_code
      ,p_state_honors_treaty_flag       =>  p_state_honors_treaty_flag
      ,p_ytd_payments                   =>  p_ytd_payments
      ,p_ytd_w2_payments                =>  p_ytd_w2_payments
      ,p_ytd_w2_withholding             =>  p_ytd_w2_withholding
      ,p_ytd_withholding_allowance      =>  p_ytd_withholding_allowance
      ,p_ytd_treaty_payments            =>  p_ytd_treaty_payments
      ,p_ytd_treaty_withheld_amt        =>  p_ytd_treaty_withheld_amt
      ,p_record_source                  =>  p_record_source
      ,p_visa_type                      =>  p_visa_type
      ,p_j_sub_type                     =>  p_j_sub_type
      ,p_primary_activity               =>  p_primary_activity
      ,p_non_us_country_code            =>  p_non_us_country_code
      ,p_citizenship_country_code       =>  p_citizenship_country_code
      ,p_constant_addl_tax              =>  p_constant_addl_tax
      ,p_date_8233_signed               =>  p_date_8233_signed
      ,p_date_w4_signed                 =>  p_date_w4_signed
      ,p_error_indicator                =>  p_error_indicator
      ,p_prev_er_treaty_benefit_amt     =>  p_prev_er_treaty_benefit_amt
      ,p_error_text                     =>  p_error_text
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                => trunc(p_effective_date)
      ,p_current_analysis              =>  p_current_analysis
      ,p_forecast_income_code          =>  p_forecast_income_code
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_ALIEN_TRANS_DATA'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_alien_trans_data
    --
  end;
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
    ROLLBACK TO update_alien_trans_data;
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
    ROLLBACK TO update_alien_trans_data;
    p_object_version_number := l_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
    --
end update_alien_trans_data;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_alien_trans_data >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_alien_trans_data
  (p_validate                       in  boolean  default false
  ,p_alien_transaction_id           in  number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_alien_trans_data';
  l_object_version_number pqp_alien_transaction_data.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_alien_trans_data;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  --
  begin
    --
    -- Start of API User Hook for the before hook of delete_alien_trans_data
    --
    pqp_alien_trans_data_bk3.delete_alien_trans_data_b
      (
       p_alien_transaction_id           =>  p_alien_transaction_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_ALIEN_TRANS_DATA'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_alien_trans_data
    --
  end;
  --
  pqp_atd_del.del
    (
     p_alien_transaction_id          => p_alien_transaction_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_alien_trans_data
    --
    pqp_alien_trans_data_bk3.delete_alien_trans_data_a
      (
       p_alien_transaction_id           =>  p_alien_transaction_id
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_ALIEN_TRANS_DATA'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_alien_trans_data
    --
  end;
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
    ROLLBACK TO delete_alien_trans_data;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO delete_alien_trans_data;
    p_object_version_number := l_object_version_number;
    raise;
    --
end delete_alien_trans_data;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_alien_transaction_id                   in     number
  ,p_object_version_number          in     number
  ) is
  --
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'lck';
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  pqp_atd_shd.lck
    (
      p_alien_transaction_id                 => p_alien_transaction_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end pqp_alien_trans_data_api;

/
