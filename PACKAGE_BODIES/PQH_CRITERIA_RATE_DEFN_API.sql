--------------------------------------------------------
--  DDL for Package Body PQH_CRITERIA_RATE_DEFN_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_CRITERIA_RATE_DEFN_API" as
/* $Header: pqcrdapi.pkb 120.2 2005/07/13 04:52:24 srenukun noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  PQH_CRITERIA_RATE_DEFN_API.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_criteria_rate_defn >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_criteria_rate_defn
(
   p_validate                      in     boolean      default false
  ,p_effective_date                in     date
  ,p_business_group_id             in     number
  ,p_criteria_rate_defn_id            out nocopy number
  ,p_short_name		           in     varchar2     default null
  ,p_name                          in     varchar2
  ,p_language_code                 in     varchar2     default hr_api.userenv_lang
  ,p_uom                           in     varchar2
  ,p_currency_code		   in     varchar2     default null
  ,p_reference_period_cd           in     varchar2     default null
  ,p_define_max_rate_flag          in	  varchar2     default null
  ,p_define_min_rate_flag          in	  varchar2     default null
  ,p_define_mid_rate_flag          in	  varchar2     default null
  ,p_define_std_rate_flag          in	  varchar2     default null
  ,p_rate_calc_cd		   in     varchar2
  ,p_rate_calc_rule		   in     number       default null
  ,p_preferential_rate_cd          in	  varchar2
  ,p_preferential_rate_rule        in 	  number       default null
  ,p_rounding_cd                   in     varchar2
  ,p_rounding_rule		   		   in     number       default null
  ,p_legislation_code 	           in     varchar2     default null
  ,p_attribute_category            in     varchar2     default null
  ,p_attribute1                    in     varchar2     default null
  ,p_attribute2                    in     varchar2     default null
  ,p_attribute3                    in     varchar2     default null
  ,p_attribute4                    in     varchar2     default null
  ,p_attribute5                    in     varchar2     default null
  ,p_attribute6                    in     varchar2     default null
  ,p_attribute7                    in     varchar2     default null
  ,p_attribute8                    in     varchar2     default null
  ,p_attribute9                    in     varchar2     default null
  ,p_attribute10                   in     varchar2     default null
  ,p_attribute11                   in     varchar2     default null
  ,p_attribute12                   in     varchar2     default null
  ,p_attribute13                   in     varchar2     default null
  ,p_attribute14                   in     varchar2     default null
  ,p_attribute15                   in     varchar2     default null
  ,p_attribute16                   in     varchar2     default null
  ,p_attribute17                   in     varchar2     default null
  ,p_attribute18                   in     varchar2     default null
  ,p_attribute19                   in     varchar2     default null
  ,p_attribute20                   in     varchar2     default null
  ,p_attribute21                   in     varchar2     default null
  ,p_attribute22                   in     varchar2     default null
  ,p_attribute23                   in     varchar2     default null
  ,p_attribute24                   in     varchar2     default null
  ,p_attribute25                   in     varchar2     default null
  ,p_attribute26                   in     varchar2     default null
  ,p_attribute27                   in     varchar2     default null
  ,p_attribute28                   in     varchar2     default null
  ,p_attribute29                   in     varchar2     default null
  ,p_attribute30                   in     varchar2     default null
  ,p_object_version_number            out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_in_out_parameter    number;
  l_effective_date      date;
  l_criteria_rate_defn_id pqh_criteria_rate_defn.criteria_rate_defn_id%type;
  l_object_version_number pqh_criteria_rate_defn.object_version_number%type;
  --
  l_proc                varchar2(72) := g_package||'create_criteria_rate_defn';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_criteria_rate_defn;
  --
  -- Remember IN OUT parameter IN values
  --
  -- l_in_out_parameter := p_in_out_parameter;

  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);

  --
  -- Call Before Process User Hook
  --
  begin
  pqh_criteria_rate_defn_bk1.create_criteria_rate_defn_b
  (p_effective_date                => l_effective_date
  ,p_business_group_id             => p_business_group_id
  ,p_short_name		           => p_short_name
  ,p_uom                           => p_uom
  ,p_currency_code		   => p_currency_code
  ,p_reference_period_cd           => p_reference_period_cd
  ,p_define_max_rate_flag          => p_define_max_rate_flag
  ,p_define_min_rate_flag          => p_define_min_rate_flag
  ,p_define_mid_rate_flag          => p_define_mid_rate_flag
  ,p_define_std_rate_flag          => p_define_std_rate_flag
  ,p_rate_calc_cd		   => p_rate_calc_cd
  ,p_rate_calc_rule		   => p_rate_calc_rule
  ,p_preferential_rate_cd          => p_preferential_rate_cd
  ,p_preferential_rate_rule        => p_preferential_rate_rule
  ,p_rounding_cd                   => p_rounding_cd
  ,p_rounding_rule		   => p_rounding_rule
  ,p_legislation_code 	           => p_legislation_code
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
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQH_CRITERIA_RATE_DEFN_API'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --



  --
  -- Process Logic
  --
  pqh_crd_ins.ins
  (p_effective_date                => l_effective_date
  ,p_short_name		           => p_short_name
  ,p_uom                           => p_uom
  ,p_currency_code		   => p_currency_code
  ,p_reference_period_cd           => p_reference_period_cd
  ,p_define_max_rate_flag          => p_define_max_rate_flag
  ,p_define_min_rate_flag          => p_define_min_rate_flag
  ,p_define_mid_rate_flag          => p_define_mid_rate_flag
  ,p_define_std_rate_flag          => p_define_std_rate_flag
  ,p_rate_calc_cd		   => p_rate_calc_cd
  ,p_rate_calc_rule		   => p_rate_calc_rule
  ,p_preferential_rate_cd          => p_preferential_rate_cd
  ,p_preferential_rate_rule        => p_preferential_rate_rule
  ,p_rounding_cd                   => p_rounding_cd
  ,p_rounding_rule		   => p_rounding_rule
  ,p_business_group_id             => p_business_group_id
  ,p_legislation_code 	           => p_legislation_code
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
  ,p_criteria_rate_defn_id         => l_criteria_rate_defn_id
  ,p_object_version_number         => l_object_version_number );


   pqh_crl_ins.ins_tl(
       p_effective_date          => l_effective_date,
       p_language_code           => p_language_code,
       p_criteria_rate_defn_id   => l_criteria_rate_defn_id,
       p_name                    => p_name
       );

  --
  -- Call After Process User Hook
  --
  begin
  pqh_criteria_rate_defn_bk1.create_criteria_rate_defn_a
  (p_effective_date                => l_effective_date
  ,p_business_group_id             => p_business_group_id
  ,p_criteria_rate_defn_id         => l_criteria_rate_defn_id
  ,p_short_name		           => p_short_name
  ,p_uom                           => p_uom
  ,p_currency_code		   => p_currency_code
  ,p_reference_period_cd           => p_reference_period_cd
  ,p_define_max_rate_flag          => p_define_max_rate_flag
  ,p_define_min_rate_flag          => p_define_min_rate_flag
  ,p_define_mid_rate_flag          => p_define_mid_rate_flag
  ,p_define_std_rate_flag          => p_define_std_rate_flag
  ,p_rate_calc_cd		   => p_rate_calc_cd
  ,p_rate_calc_rule		   => p_rate_calc_rule
  ,p_preferential_rate_cd          => p_preferential_rate_cd
  ,p_preferential_rate_rule        => p_preferential_rate_rule
  ,p_rounding_cd                   => p_rounding_cd
  ,p_rounding_rule		   => p_rounding_rule
  ,p_legislation_code 	           => p_legislation_code
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
  ,p_object_version_number         => l_object_version_number );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQH_CRITERIA_RATE_DEFN_API'
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
  -- Set all IN OUT and OUT parameters with out values
  --
  p_criteria_rate_defn_id  := l_criteria_rate_defn_id;
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_criteria_rate_defn;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_criteria_rate_defn_id  := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_criteria_rate_defn;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_criteria_rate_defn_id  := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_criteria_rate_defn;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_criteria_rate_defn >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_criteria_rate_defn
  (p_validate                      in     boolean      default false
  ,p_effective_date                in     date
  ,p_business_group_id             in     number
  ,p_criteria_rate_defn_id         in     number
  ,p_short_name		           in     varchar2     default hr_api.g_varchar2
  ,p_name                          in     varchar2
  ,p_language_code                 in     varchar2     default hr_api.userenv_lang
  ,p_uom                           in     varchar2
  ,p_currency_code		   in     varchar2     default hr_api.g_varchar2
  ,p_reference_period_cd           in     varchar2     default hr_api.g_varchar2
  ,p_define_max_rate_flag          in	  varchar2     default hr_api.g_varchar2
  ,p_define_min_rate_flag          in	  varchar2     default hr_api.g_varchar2
  ,p_define_mid_rate_flag          in	  varchar2     default hr_api.g_varchar2
  ,p_define_std_rate_flag          in	  varchar2     default hr_api.g_varchar2
  ,p_rate_calc_cd		   in     varchar2
  ,p_rate_calc_rule		   in     number       default hr_api.g_number
  ,p_preferential_rate_cd          in	  varchar2
  ,p_preferential_rate_rule        in 	  number       default hr_api.g_number
  ,p_rounding_cd                   in     varchar2
  ,p_rounding_rule		   in     number       default hr_api.g_number
  ,p_legislation_code 	           in     varchar2     default hr_api.g_varchar2
  ,p_attribute_category            in     varchar2     default hr_api.g_varchar2
  ,p_attribute1                    in     varchar2     default hr_api.g_varchar2
  ,p_attribute2                    in     varchar2     default hr_api.g_varchar2
  ,p_attribute3                    in     varchar2     default hr_api.g_varchar2
  ,p_attribute4                    in     varchar2     default hr_api.g_varchar2
  ,p_attribute5                    in     varchar2     default hr_api.g_varchar2
  ,p_attribute6                    in     varchar2     default hr_api.g_varchar2
  ,p_attribute7                    in     varchar2     default hr_api.g_varchar2
  ,p_attribute8                    in     varchar2     default hr_api.g_varchar2
  ,p_attribute9                    in     varchar2     default hr_api.g_varchar2
  ,p_attribute10                   in     varchar2     default hr_api.g_varchar2
  ,p_attribute11                   in     varchar2     default hr_api.g_varchar2
  ,p_attribute12                   in     varchar2     default hr_api.g_varchar2
  ,p_attribute13                   in     varchar2     default hr_api.g_varchar2
  ,p_attribute14                   in     varchar2     default hr_api.g_varchar2
  ,p_attribute15                   in     varchar2     default hr_api.g_varchar2
  ,p_attribute16                   in     varchar2     default hr_api.g_varchar2
  ,p_attribute17                   in     varchar2     default hr_api.g_varchar2
  ,p_attribute18                   in     varchar2     default hr_api.g_varchar2
  ,p_attribute19                   in     varchar2     default hr_api.g_varchar2
  ,p_attribute20                   in     varchar2     default hr_api.g_varchar2
  ,p_attribute21                   in     varchar2     default hr_api.g_varchar2
  ,p_attribute22                   in     varchar2     default hr_api.g_varchar2
  ,p_attribute23                   in     varchar2     default hr_api.g_varchar2
  ,p_attribute24                   in     varchar2     default hr_api.g_varchar2
  ,p_attribute25                   in     varchar2     default hr_api.g_varchar2
  ,p_attribute26                   in     varchar2     default hr_api.g_varchar2
  ,p_attribute27                   in     varchar2     default hr_api.g_varchar2
  ,p_attribute28                   in     varchar2     default hr_api.g_varchar2
  ,p_attribute29                   in     varchar2     default hr_api.g_varchar2
  ,p_attribute30                   in     varchar2     default hr_api.g_varchar2
  ,p_object_version_number         in out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_in_out_parameter    number;
  l_effective_date      date;
  l_object_version_number pqh_criteria_rate_defn.object_version_number%TYPE;
  l_proc                varchar2(72) := g_package||'update_criteria_rate_defn';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_criteria_rate_defn;
  --
  -- Remember IN OUT parameter IN values
  --
  -- l_in_out_parameter := p_in_out_parameter;
   l_object_version_number := p_object_version_number;

  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);

  --
  -- Call Before Process User Hook
  --
  begin
  pqh_criteria_rate_defn_bk2.update_criteria_rate_defn_b
  (p_effective_date                => l_effective_date
  ,p_business_group_id             => p_business_group_id
  ,p_criteria_rate_defn_id         => p_criteria_rate_defn_id
  ,p_short_name		           => p_short_name
  ,p_uom                           => p_uom
  ,p_currency_code		   => p_currency_code
  ,p_reference_period_cd           => p_reference_period_cd
  ,p_define_max_rate_flag          => p_define_max_rate_flag
  ,p_define_min_rate_flag          => p_define_min_rate_flag
  ,p_define_mid_rate_flag          => p_define_mid_rate_flag
  ,p_define_std_rate_flag          => p_define_std_rate_flag
  ,p_rate_calc_cd		   => p_rate_calc_cd
  ,p_rate_calc_rule		   => p_rate_calc_rule
  ,p_preferential_rate_cd          => p_preferential_rate_cd
  ,p_preferential_rate_rule        => p_preferential_rate_rule
  ,p_rounding_cd                   => p_rounding_cd
  ,p_rounding_rule		   => p_rounding_rule
  ,p_legislation_code 	           => p_legislation_code
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
  ,p_object_version_number         => p_object_version_number
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQH_CRITERIA_RATE_DEFN_API'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --



  --
  -- Process Logic
  --
  pqh_crd_upd.upd
  (p_effective_date                => l_effective_date
  ,p_business_group_id             => p_business_group_id
  ,p_criteria_rate_defn_id         => p_criteria_rate_defn_id
  ,p_short_name		           => p_short_name
  ,p_uom                           => p_uom
  ,p_currency_code		   => p_currency_code
  ,p_reference_period_cd           => p_reference_period_cd
  ,p_define_max_rate_flag          => p_define_max_rate_flag
  ,p_define_min_rate_flag          => p_define_min_rate_flag
  ,p_define_mid_rate_flag          => p_define_mid_rate_flag
  ,p_define_std_rate_flag          => p_define_std_rate_flag
  ,p_rate_calc_cd		   => p_rate_calc_cd
  ,p_rate_calc_rule		   => p_rate_calc_rule
  ,p_preferential_rate_cd          => p_preferential_rate_cd
  ,p_preferential_rate_rule        => p_preferential_rate_rule
  ,p_rounding_cd                   => p_rounding_cd
  ,p_rounding_rule		   => p_rounding_rule
  ,p_legislation_code 	           => p_legislation_code
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
  ,p_object_version_number         => l_object_version_number );


   pqh_crl_upd.upd_tl(
       p_effective_date          => l_effective_date,
       p_language_code           => p_language_code,
       p_criteria_rate_defn_id   => p_criteria_rate_defn_id,
       p_name                    => p_name
       );

  --
  -- Call After Process User Hook
  --
  begin
  pqh_criteria_rate_defn_bk2.update_criteria_rate_defn_a
  (p_effective_date                => l_effective_date
  ,p_business_group_id             => p_business_group_id
  ,p_criteria_rate_defn_id         => p_criteria_rate_defn_id
  ,p_short_name		           => p_short_name
  ,p_uom                           => p_uom
  ,p_currency_code		   => p_currency_code
  ,p_reference_period_cd           => p_reference_period_cd
  ,p_define_max_rate_flag          => p_define_max_rate_flag
  ,p_define_min_rate_flag          => p_define_min_rate_flag
  ,p_define_mid_rate_flag          => p_define_mid_rate_flag
  ,p_define_std_rate_flag          => p_define_std_rate_flag
  ,p_rate_calc_cd		   => p_rate_calc_cd
  ,p_rate_calc_rule		   => p_rate_calc_rule
  ,p_preferential_rate_cd          => p_preferential_rate_cd
  ,p_preferential_rate_rule        => p_preferential_rate_rule
  ,p_rounding_cd                   => p_rounding_cd
  ,p_rounding_rule		   => p_rounding_rule
  ,p_legislation_code 	           => p_legislation_code
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
  ,p_object_version_number         => l_object_version_number );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQH_CRITERIA_RATE_DEFN_API'
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
  -- Set all IN OUT and OUT parameters with out values
  --
   p_object_version_number := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_criteria_rate_defn;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number := l_object_version_number;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_criteria_rate_defn;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_object_version_number := l_object_version_number;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_criteria_rate_defn;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_criteria_rate_defn >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_criteria_rate_defn
  (p_validate                      in     boolean           default false
  ,p_effective_date                in     date
  ,p_criteria_rate_defn_id         in     number
  ,p_object_version_number         in     number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_in_out_parameter    number;
  l_effective_date      date;
  l_object_version_number pqh_criteria_rate_defn.object_version_number%type;
  --
  l_proc                varchar2(72) := g_package||'delete_criteria_rate_defn';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_criteria_rate_defn;
  --
  -- Remember IN OUT parameter IN values
  --
  -- l_in_out_parameter := p_in_out_parameter;
  l_object_version_number := p_object_version_number;

  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);

  --
  -- Call Before Process User Hook
  --
  begin
  pqh_criteria_rate_defn_bk3.delete_criteria_rate_defn_b
  (p_effective_date                => l_effective_date
  ,p_criteria_rate_defn_id         => p_criteria_rate_defn_id
  ,p_object_version_number         => l_object_version_number
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQH_CRITERIA_RATE_DEFN_API'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --



  --
  -- Process Logic
  --
  pqh_crd_del.del
  (p_criteria_rate_defn_id         => p_criteria_rate_defn_id
  ,p_object_version_number         => l_object_version_number );


   pqh_crl_del.del_tl(
       p_criteria_rate_defn_id   => p_criteria_rate_defn_id
       );
  --
  -- Call After Process User Hook
  --
  begin
  pqh_criteria_rate_defn_bk3.delete_criteria_rate_defn_a
  (p_effective_date                => l_effective_date
  ,p_criteria_rate_defn_id         => p_criteria_rate_defn_id
  ,p_object_version_number         => l_object_version_number );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQH_CRITERIA_RATE_DEFN_API'
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
  -- Set all IN OUT and OUT parameters with out values
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_criteria_rate_defn;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to delete_criteria_rate_defn;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_criteria_rate_defn;
--
--
end PQH_CRITERIA_RATE_DEFN_API;

/
