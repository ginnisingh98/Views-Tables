--------------------------------------------------------
--  DDL for Package Body PQP_ANALYZED_ALIEN_DET_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_ANALYZED_ALIEN_DET_API" as
/* $Header: pqdetapi.pkb 115.7 2003/01/22 00:54:43 tmehra ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  pqp_analyzed_alien_det_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_analyzed_alien_det >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_analyzed_alien_det
  (p_validate                       in  boolean   default false
  ,p_analyzed_data_details_id       out nocopy number
  ,p_analyzed_data_id               in  number    default null
  ,p_income_code                    in  varchar2  default null
  ,p_withholding_rate               in  number    default null
  ,p_income_code_sub_type           in  varchar2  default null
  ,p_exemption_code                 in  varchar2  default null
  ,p_maximum_benefit_amount         in  number    default null
  ,p_retro_lose_ben_amt_flag        in  varchar2  default null
  ,p_date_benefit_ends              in  date      default null
  ,p_retro_lose_ben_date_flag       in  varchar2  default null
  ,p_nra_exempt_from_ss             in  varchar2  default null
  ,p_nra_exempt_from_medicare       in  varchar2  default null
  ,p_student_exempt_from_ss         in  varchar2  default null
  ,p_student_exempt_from_medi       in  varchar2  default null
  ,p_addl_withholding_flag          in  varchar2  default null
  ,p_constant_addl_tax              in  number    default null
  ,p_addl_withholding_amt           in  number    default null
  ,p_addl_wthldng_amt_period_type   in  varchar2  default null
  ,p_personal_exemption             in  number    default null
  ,p_addl_exemption_allowed         in  number    default null
  ,p_treaty_ben_allowed_flag        in  varchar2  default null
  ,p_treaty_benefits_start_date     in  date      default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ,p_retro_loss_notification_sent   in  varchar2  default null
  ,p_current_analysis               in  varchar2  default null
  ,p_forecast_income_code           in  varchar2  default null
  ) is
  --
  -- Declare cursors and local variables
  --
  l_analyzed_data_details_id pqp_analyzed_alien_details.analyzed_data_details_id%TYPE;
  l_proc varchar2(72) := g_package||'create_analyzed_alien_det';
  l_object_version_number pqp_analyzed_alien_details.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_analyzed_alien_det;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_analyzed_alien_det
    --
    pqp_analyzed_alien_det_bk1.create_analyzed_alien_det_b
      (
       p_analyzed_data_id               =>  p_analyzed_data_id
      ,p_income_code                    =>  p_income_code
      ,p_withholding_rate               =>  p_withholding_rate
      ,p_income_code_sub_type           =>  p_income_code_sub_type
      ,p_exemption_code                 =>  p_exemption_code
      ,p_maximum_benefit_amount         =>  p_maximum_benefit_amount
      ,p_retro_lose_ben_amt_flag        =>  p_retro_lose_ben_amt_flag
      ,p_date_benefit_ends              =>  p_date_benefit_ends
      ,p_retro_lose_ben_date_flag       =>  p_retro_lose_ben_date_flag
      ,p_nra_exempt_from_ss             =>  p_nra_exempt_from_ss
      ,p_nra_exempt_from_medicare       =>  p_nra_exempt_from_medicare
      ,p_student_exempt_from_ss         =>  p_student_exempt_from_ss
      ,p_student_exempt_from_medi       =>  p_student_exempt_from_medi
      ,p_addl_withholding_flag          =>  p_addl_withholding_flag
      ,p_constant_addl_tax              =>  p_constant_addl_tax
      ,p_addl_withholding_amt           =>  p_addl_withholding_amt
      ,p_addl_wthldng_amt_period_type   =>  p_addl_wthldng_amt_period_type
      ,p_personal_exemption             =>  p_personal_exemption
      ,p_addl_exemption_allowed         =>  p_addl_exemption_allowed
      ,p_treaty_ben_allowed_flag        =>  p_treaty_ben_allowed_flag
      ,p_treaty_benefits_start_date     =>  p_treaty_benefits_start_date
      ,p_effective_date                 =>  trunc(p_effective_date)
      ,p_retro_loss_notification_sent   =>  p_retro_loss_notification_sent
      ,p_current_analysis               =>  p_current_analysis
      ,p_forecast_income_code           =>  p_forecast_income_code
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_ANALYZED_ALIEN_DET'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_analyzed_alien_det
    --
  end;
  --
  pqp_det_ins.ins
    (
     p_analyzed_data_details_id      => l_analyzed_data_details_id
    ,p_analyzed_data_id              => p_analyzed_data_id
    ,p_income_code                   => p_income_code
    ,p_withholding_rate              => p_withholding_rate
    ,p_income_code_sub_type          => p_income_code_sub_type
    ,p_exemption_code                => p_exemption_code
    ,p_maximum_benefit_amount        => p_maximum_benefit_amount
    ,p_retro_lose_ben_amt_flag       => p_retro_lose_ben_amt_flag
    ,p_date_benefit_ends             => p_date_benefit_ends
    ,p_retro_lose_ben_date_flag      => p_retro_lose_ben_date_flag
    ,p_nra_exempt_from_ss            => p_nra_exempt_from_ss
    ,p_nra_exempt_from_medicare      => p_nra_exempt_from_medicare
    ,p_student_exempt_from_ss        => p_student_exempt_from_ss
    ,p_student_exempt_from_medi      => p_student_exempt_from_medi
    ,p_addl_withholding_flag         => p_addl_withholding_flag
    ,p_constant_addl_tax             => p_constant_addl_tax
    ,p_addl_withholding_amt          => p_addl_withholding_amt
    ,p_addl_wthldng_amt_period_type  => p_addl_wthldng_amt_period_type
    ,p_personal_exemption            => p_personal_exemption
    ,p_addl_exemption_allowed        => p_addl_exemption_allowed
    ,p_treaty_ben_allowed_flag       => p_treaty_ben_allowed_flag
    ,p_treaty_benefits_start_date    => p_treaty_benefits_start_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_retro_loss_notification_sent  => p_retro_loss_notification_sent
    ,p_current_analysis              =>  p_current_analysis
    ,p_forecast_income_code          =>  p_forecast_income_code
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_analyzed_alien_det
    --
    pqp_analyzed_alien_det_bk1.create_analyzed_alien_det_a
      (
       p_analyzed_data_details_id       =>  l_analyzed_data_details_id
      ,p_analyzed_data_id               =>  p_analyzed_data_id
      ,p_income_code                    =>  p_income_code
      ,p_withholding_rate               =>  p_withholding_rate
      ,p_income_code_sub_type           =>  p_income_code_sub_type
      ,p_exemption_code                 =>  p_exemption_code
      ,p_maximum_benefit_amount         =>  p_maximum_benefit_amount
      ,p_retro_lose_ben_amt_flag        =>  p_retro_lose_ben_amt_flag
      ,p_date_benefit_ends              =>  p_date_benefit_ends
      ,p_retro_lose_ben_date_flag       =>  p_retro_lose_ben_date_flag
      ,p_nra_exempt_from_ss             =>  p_nra_exempt_from_ss
      ,p_nra_exempt_from_medicare       =>  p_nra_exempt_from_medicare
      ,p_student_exempt_from_ss         =>  p_student_exempt_from_ss
      ,p_student_exempt_from_medi       =>  p_student_exempt_from_medi
      ,p_addl_withholding_flag          =>  p_addl_withholding_flag
      ,p_constant_addl_tax              =>  p_constant_addl_tax
      ,p_addl_withholding_amt           =>  p_addl_withholding_amt
      ,p_addl_wthldng_amt_period_type   =>  p_addl_wthldng_amt_period_type
      ,p_personal_exemption             =>  p_personal_exemption
      ,p_addl_exemption_allowed         =>  p_addl_exemption_allowed
      ,p_treaty_ben_allowed_flag        =>  p_treaty_ben_allowed_flag
      ,p_treaty_benefits_start_date     =>  p_treaty_benefits_start_date
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
      ,p_retro_loss_notification_sent   => p_retro_loss_notification_sent
      ,p_current_analysis              =>  p_current_analysis
      ,p_forecast_income_code          =>  p_forecast_income_code
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_ANALYZED_ALIEN_DET'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_analyzed_alien_det
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
  p_analyzed_data_details_id := l_analyzed_data_details_id;
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
    ROLLBACK TO create_analyzed_alien_det;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_analyzed_data_details_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_analyzed_alien_det;
    p_analyzed_data_details_id := null;
    p_object_version_number := null;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 90);

    raise;
    --
end create_analyzed_alien_det;
-- ----------------------------------------------------------------------------
-- |------------------------< update_analyzed_alien_det >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_analyzed_alien_det
  (p_validate                       in  boolean   default false
  ,p_analyzed_data_details_id       in  number
  ,p_analyzed_data_id               in  number    default hr_api.g_number
  ,p_income_code                    in  varchar2  default hr_api.g_varchar2
  ,p_withholding_rate               in  number    default hr_api.g_number
  ,p_income_code_sub_type           in  varchar2  default hr_api.g_varchar2
  ,p_exemption_code                 in  varchar2  default hr_api.g_varchar2
  ,p_maximum_benefit_amount         in  number    default hr_api.g_number
  ,p_retro_lose_ben_amt_flag        in  varchar2  default hr_api.g_varchar2
  ,p_date_benefit_ends              in  date      default hr_api.g_date
  ,p_retro_lose_ben_date_flag       in  varchar2  default hr_api.g_varchar2
  ,p_nra_exempt_from_ss             in  varchar2  default hr_api.g_varchar2
  ,p_nra_exempt_from_medicare       in  varchar2  default hr_api.g_varchar2
  ,p_student_exempt_from_ss         in  varchar2  default hr_api.g_varchar2
  ,p_student_exempt_from_medi       in  varchar2  default hr_api.g_varchar2
  ,p_addl_withholding_flag          in  varchar2  default hr_api.g_varchar2
  ,p_constant_addl_tax              in  number    default hr_api.g_number
  ,p_addl_withholding_amt           in  number    default hr_api.g_number
  ,p_addl_wthldng_amt_period_type   in  varchar2  default hr_api.g_varchar2
  ,p_personal_exemption             in  number    default hr_api.g_number
  ,p_addl_exemption_allowed         in  number    default hr_api.g_number
  ,p_treaty_ben_allowed_flag        in  varchar2  default hr_api.g_varchar2
  ,p_treaty_benefits_start_date     in  date      default hr_api.g_date
  ,p_object_version_number          in  out nocopy number
  ,p_effective_date                 in  date
  ,p_retro_loss_notification_sent   in  varchar2  default hr_api.g_varchar2
  ,p_current_analysis               in  varchar2  default hr_api.g_varchar2
  ,p_forecast_income_code           in  varchar2  default hr_api.g_varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_analyzed_alien_det';
  l_object_version_number pqp_analyzed_alien_details.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_analyzed_alien_det;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_analyzed_alien_det
    --
    pqp_analyzed_alien_det_bk2.update_analyzed_alien_det_b
      (
       p_analyzed_data_details_id       =>  p_analyzed_data_details_id
      ,p_analyzed_data_id               =>  p_analyzed_data_id
      ,p_income_code                    =>  p_income_code
      ,p_withholding_rate               =>  p_withholding_rate
      ,p_income_code_sub_type           =>  p_income_code_sub_type
      ,p_exemption_code                 =>  p_exemption_code
      ,p_maximum_benefit_amount         =>  p_maximum_benefit_amount
      ,p_retro_lose_ben_amt_flag        =>  p_retro_lose_ben_amt_flag
      ,p_date_benefit_ends              =>  p_date_benefit_ends
      ,p_retro_lose_ben_date_flag       =>  p_retro_lose_ben_date_flag
      ,p_nra_exempt_from_ss             =>  p_nra_exempt_from_ss
      ,p_nra_exempt_from_medicare       =>  p_nra_exempt_from_medicare
      ,p_student_exempt_from_ss         =>  p_student_exempt_from_ss
      ,p_student_exempt_from_medi       =>  p_student_exempt_from_medi
      ,p_addl_withholding_flag          =>  p_addl_withholding_flag
      ,p_constant_addl_tax              =>  p_constant_addl_tax
      ,p_addl_withholding_amt           =>  p_addl_withholding_amt
      ,p_addl_wthldng_amt_period_type   =>  p_addl_wthldng_amt_period_type
      ,p_personal_exemption             =>  p_personal_exemption
      ,p_addl_exemption_allowed         =>  p_addl_exemption_allowed
      ,p_treaty_ben_allowed_flag        =>  p_treaty_ben_allowed_flag
      ,p_treaty_benefits_start_date     =>  p_treaty_benefits_start_date
      ,p_object_version_number          =>  p_object_version_number
      ,p_effective_date                 =>  trunc(p_effective_date)
      ,p_retro_loss_notification_sent   =>  p_retro_loss_notification_sent
      ,p_current_analysis               =>  p_current_analysis
      ,p_forecast_income_code           =>  p_forecast_income_code
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_ANALYZED_ALIEN_DET'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_analyzed_alien_det
    --
  end;
  --
  pqp_det_upd.upd
    (
     p_analyzed_data_details_id      => p_analyzed_data_details_id
    ,p_analyzed_data_id              => p_analyzed_data_id
    ,p_income_code                   => p_income_code
    ,p_withholding_rate              => p_withholding_rate
    ,p_income_code_sub_type          => p_income_code_sub_type
    ,p_exemption_code                => p_exemption_code
    ,p_maximum_benefit_amount        => p_maximum_benefit_amount
    ,p_retro_lose_ben_amt_flag       => p_retro_lose_ben_amt_flag
    ,p_date_benefit_ends             => p_date_benefit_ends
    ,p_retro_lose_ben_date_flag      => p_retro_lose_ben_date_flag
    ,p_nra_exempt_from_ss            => p_nra_exempt_from_ss
    ,p_nra_exempt_from_medicare      => p_nra_exempt_from_medicare
    ,p_student_exempt_from_ss        => p_student_exempt_from_ss
    ,p_student_exempt_from_medi      => p_student_exempt_from_medi
    ,p_addl_withholding_flag         => p_addl_withholding_flag
    ,p_constant_addl_tax             => p_constant_addl_tax
    ,p_addl_withholding_amt          => p_addl_withholding_amt
    ,p_addl_wthldng_amt_period_type  => p_addl_wthldng_amt_period_type
    ,p_personal_exemption            => p_personal_exemption
    ,p_addl_exemption_allowed        => p_addl_exemption_allowed
    ,p_treaty_ben_allowed_flag       => p_treaty_ben_allowed_flag
    ,p_treaty_benefits_start_date    => p_treaty_benefits_start_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_retro_loss_notification_sent  => p_retro_loss_notification_sent
    ,p_current_analysis               =>  p_current_analysis
    ,p_forecast_income_code           =>  p_forecast_income_code
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_analyzed_alien_det
    --
    pqp_analyzed_alien_det_bk2.update_analyzed_alien_det_a
      (
       p_analyzed_data_details_id       =>  p_analyzed_data_details_id
      ,p_analyzed_data_id               =>  p_analyzed_data_id
      ,p_income_code                    =>  p_income_code
      ,p_withholding_rate               =>  p_withholding_rate
      ,p_income_code_sub_type           =>  p_income_code_sub_type
      ,p_exemption_code                 =>  p_exemption_code
      ,p_maximum_benefit_amount         =>  p_maximum_benefit_amount
      ,p_retro_lose_ben_amt_flag        =>  p_retro_lose_ben_amt_flag
      ,p_date_benefit_ends              =>  p_date_benefit_ends
      ,p_retro_lose_ben_date_flag       =>  p_retro_lose_ben_date_flag
      ,p_nra_exempt_from_ss             =>  p_nra_exempt_from_ss
      ,p_nra_exempt_from_medicare       =>  p_nra_exempt_from_medicare
      ,p_student_exempt_from_ss         =>  p_student_exempt_from_ss
      ,p_student_exempt_from_medi       =>  p_student_exempt_from_medi
      ,p_addl_withholding_flag          =>  p_addl_withholding_flag
      ,p_constant_addl_tax              =>  p_constant_addl_tax
      ,p_addl_withholding_amt           =>  p_addl_withholding_amt
      ,p_addl_wthldng_amt_period_type   =>  p_addl_wthldng_amt_period_type
      ,p_personal_exemption             =>  p_personal_exemption
      ,p_addl_exemption_allowed         =>  p_addl_exemption_allowed
      ,p_treaty_ben_allowed_flag        =>  p_treaty_ben_allowed_flag
      ,p_treaty_benefits_start_date     =>  p_treaty_benefits_start_date
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
      ,p_retro_loss_notification_sent   => p_retro_loss_notification_sent
      ,p_current_analysis               =>  p_current_analysis
      ,p_forecast_income_code           =>  p_forecast_income_code
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_ANALYZED_ALIEN_DET'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_analyzed_alien_det
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
    ROLLBACK TO update_analyzed_alien_det;
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
    ROLLBACK TO update_analyzed_alien_det;
    p_object_version_number := l_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
    --
end update_analyzed_alien_det;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_analyzed_alien_det >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_analyzed_alien_det
  (p_validate                       in  boolean  default false
  ,p_analyzed_data_details_id       in  number
  ,p_object_version_number          in  out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_analyzed_alien_det';
  l_object_version_number pqp_analyzed_alien_details.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_analyzed_alien_det;
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
    -- Start of API User Hook for the before hook of delete_analyzed_alien_det
    --
    pqp_analyzed_alien_det_bk3.delete_analyzed_alien_det_b
      (
       p_analyzed_data_details_id       =>  p_analyzed_data_details_id
      ,p_object_version_number          =>  p_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_ANALYZED_ALIEN_DET'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_analyzed_alien_det
    --
  end;
  --
  pqp_det_del.del
    (
     p_analyzed_data_details_id      => p_analyzed_data_details_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_analyzed_alien_det
    --
    pqp_analyzed_alien_det_bk3.delete_analyzed_alien_det_a
      (
       p_analyzed_data_details_id       =>  p_analyzed_data_details_id
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                   => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_ANALYZED_ALIEN_DET'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_analyzed_alien_det
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
    ROLLBACK TO delete_analyzed_alien_det;
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
    ROLLBACK TO delete_analyzed_alien_det;
    p_object_version_number := l_object_version_number;
    raise;
    --
end delete_analyzed_alien_det;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_analyzed_data_details_id                   in     number
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
  pqp_det_shd.lck
    (
      p_analyzed_data_details_id                 => p_analyzed_data_details_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end pqp_analyzed_alien_det_api;

/
