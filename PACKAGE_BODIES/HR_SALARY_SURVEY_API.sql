--------------------------------------------------------
--  DDL for Package Body HR_SALARY_SURVEY_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_SALARY_SURVEY_API" as
/* $Header: pepssapi.pkb 115.4 2003/02/12 11:37:46 eumenyio ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_salary_survey_api.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_salary_survey >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_salary_survey
  (p_validate                      in     boolean  default false
  ,p_survey_name                   in     varchar2
  ,p_survey_company_code           in     varchar2
  ,p_identifier                    in     varchar2
--ras  ,p_currency_code                 in     varchar2
  ,p_survey_type_code              in     varchar2
  ,p_base_region                   in     varchar2 default null
  ,p_effective_date                in     date     default null
  ,p_attribute_category            in     varchar2 default null
  ,p_attribute1                    in     varchar2 default null
  ,p_attribute2                    in     varchar2 default null
  ,p_attribute3                    in     varchar2 default null
  ,p_attribute4                    in     varchar2 default null
  ,p_attribute5                    in     varchar2 default null
  ,p_attribute6                    in     varchar2 default null
  ,p_attribute7                    in     varchar2 default null
  ,p_attribute8                    in     varchar2 default null
  ,p_attribute9                    in     varchar2 default null
  ,p_attribute10                   in     varchar2 default null
  ,p_attribute11                   in     varchar2 default null
  ,p_attribute12                   in     varchar2 default null
  ,p_attribute13                   in     varchar2 default null
  ,p_attribute14                   in     varchar2 default null
  ,p_attribute15                   in     varchar2 default null
  ,p_attribute16                   in     varchar2 default null
  ,p_attribute17                   in     varchar2 default null
  ,p_attribute18                   in     varchar2 default null
  ,p_attribute19                   in     varchar2 default null
  ,p_attribute20                   in     varchar2 default null
  ,p_salary_survey_id                 out nocopy number
  ,p_object_version_number            out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'create_salary_survey';
  --
  l_salary_survey_id      per_salary_surveys.salary_survey_id%TYPE;
  l_object_version_number per_salary_surveys.object_version_number%TYPE;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_salary_survey;
  hr_utility.set_location(l_proc, 20);
  --
  -- Call Before Process User Hook
  --
  begin
    hr_salary_survey_bk1.create_salary_survey_b
      (p_survey_name           => p_survey_name
      ,p_survey_company_code   => p_survey_company_code
      ,p_identifier            => p_identifier
--ras      ,p_currency_code         => p_currency_code
      ,p_survey_type_code      => p_survey_type_code
      ,p_base_region           => p_base_region
      ,p_effective_date        => p_effective_date
      ,p_attribute_category    => p_attribute_category
      ,p_attribute1            => p_attribute1
      ,p_attribute2            => p_attribute2
      ,p_attribute3            => p_attribute3
      ,p_attribute4            => p_attribute4
      ,p_attribute5            => p_attribute5
      ,p_attribute6            => p_attribute6
      ,p_attribute7            => p_attribute7
      ,p_attribute8            => p_attribute8
      ,p_attribute9            => p_attribute9
      ,p_attribute10           => p_attribute10
      ,p_attribute11           => p_attribute11
      ,p_attribute12           => p_attribute12
      ,p_attribute13           => p_attribute13
      ,p_attribute14           => p_attribute14
      ,p_attribute15           => p_attribute15
      ,p_attribute16           => p_attribute16
      ,p_attribute17           => p_attribute17
      ,p_attribute18           => p_attribute18
      ,p_attribute19           => p_attribute19
      ,p_attribute20           => p_attribute20
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_salary_survey'
        ,p_hook_type   => 'BP'
        );
  end;
  hr_utility.set_location(l_proc, 30);
  --
  -- Process Logic
  --
  per_pss_ins.ins(p_salary_survey_id      => l_salary_survey_id
                 ,p_object_version_number => l_object_version_number
                 ,p_survey_name           => p_survey_name
                 ,p_survey_company_code   => p_survey_company_code
                 ,p_identifier            => p_identifier
--ras                 ,p_currency_code         => p_currency_code
                 ,p_survey_type_code      => p_survey_type_code
                 ,p_base_region           => p_base_region
                 ,p_effective_date        => p_effective_date
                 ,p_attribute_category    => p_attribute_category
                 ,p_attribute1            => p_attribute1
                 ,p_attribute2            => p_attribute2
                 ,p_attribute3            => p_attribute3
                 ,p_attribute4            => p_attribute4
                 ,p_attribute5            => p_attribute5
                 ,p_attribute6            => p_attribute6
                 ,p_attribute7            => p_attribute7
                 ,p_attribute8            => p_attribute8
                 ,p_attribute9            => p_attribute9
                 ,p_attribute10           => p_attribute10
                 ,p_attribute11           => p_attribute11
                 ,p_attribute12           => p_attribute12
                 ,p_attribute13           => p_attribute13
                 ,p_attribute14           => p_attribute14
                 ,p_attribute15           => p_attribute15
                 ,p_attribute16           => p_attribute16
                 ,p_attribute17           => p_attribute17
                 ,p_attribute18           => p_attribute18
                 ,p_attribute19           => p_attribute19
                 ,p_attribute20           => p_attribute20
                 );
  hr_utility.set_location(l_proc, 50);
  --
  -- Call After Process User Hook
  --
  begin
    hr_salary_survey_bk1.create_salary_survey_a
      (p_survey_name           => p_survey_name
      ,p_survey_company_code   => p_survey_company_code
      ,p_identifier            => p_identifier
--ras      ,p_currency_code         => p_currency_code
      ,p_survey_type_code      => p_survey_type_code
      ,p_base_region           => p_base_region
      ,p_effective_date        => p_effective_date
      ,p_attribute_category    => p_attribute_category
      ,p_attribute1            => p_attribute1
      ,p_attribute2            => p_attribute2
      ,p_attribute3            => p_attribute3
      ,p_attribute4            => p_attribute4
      ,p_attribute5            => p_attribute5
      ,p_attribute6            => p_attribute6
      ,p_attribute7            => p_attribute7
      ,p_attribute8            => p_attribute8
      ,p_attribute9            => p_attribute9
      ,p_attribute10           => p_attribute10
      ,p_attribute11           => p_attribute11
      ,p_attribute12           => p_attribute12
      ,p_attribute13           => p_attribute13
      ,p_attribute14           => p_attribute14
      ,p_attribute15           => p_attribute15
      ,p_attribute16           => p_attribute16
      ,p_attribute17           => p_attribute17
      ,p_attribute18           => p_attribute18
      ,p_attribute19           => p_attribute19
      ,p_attribute20           => p_attribute20
      ,p_salary_survey_id      => l_salary_survey_id
      ,p_object_version_number => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_salary_survey'
        ,p_hook_type   => 'AP'
        );
  end;
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    --
    raise hr_api.validate_enabled;
    --
  end if;
  --
  -- Set all output arguments
  --
  p_salary_survey_id       := l_salary_survey_id;
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_salary_survey;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_salary_survey_id       := null;
    p_object_version_number  := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    p_salary_survey_id       := null;
    p_object_version_number  := null;
    rollback to create_salary_survey;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    --
    raise;
    --
end create_salary_survey;
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_salary_survey >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_salary_survey
  (p_validate                      in     boolean  default false
  ,p_survey_name                   in     varchar2 default hr_api.g_varchar2
--ras  ,p_currency_code                 in     varchar2 default hr_api.g_varchar2
  ,p_survey_type_code              in     varchar2 default hr_api.g_varchar2
  ,p_base_region                   in     varchar2 default hr_api.g_varchar2
  ,p_effective_date                in     date     default hr_api.g_date
  ,p_attribute_category            in     varchar2 default hr_api.g_varchar2
  ,p_attribute1                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute2                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute3                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute4                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute5                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute6                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute7                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute8                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute9                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute10                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute11                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute12                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute13                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute14                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute15                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute16                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute17                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute18                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute19                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute20                   in     varchar2 default hr_api.g_varchar2
  ,p_salary_survey_id              in     number
  ,p_object_version_number         in out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'update_salary_survey';
  --
  l_salary_survey_id      per_salary_surveys.salary_survey_id%TYPE;
  l_object_version_number per_salary_surveys.object_version_number%TYPE;
  l_temp_ovn              number       := p_object_version_number;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_salary_survey;
  hr_utility.set_location(l_proc, 20);
  --
  -- Call Before Process User Hook
  --
  l_object_version_number := p_object_version_number;
  l_salary_survey_id      := p_salary_survey_id;
  --
  begin
    hr_salary_survey_bk2.update_salary_survey_b
     (p_survey_name           => p_survey_name,
--ras      p_currency_code         => p_currency_code,
      p_survey_type_code      => p_survey_type_code,
      p_base_region           => p_base_region,
      p_effective_date        => p_effective_date,
      p_attribute_category    => p_attribute_category,
      p_attribute1            => p_attribute1,
      p_attribute2            => p_attribute2,
      p_attribute3            => p_attribute3,
      p_attribute4            => p_attribute4,
      p_attribute5            => p_attribute5,
      p_attribute6            => p_attribute6,
      p_attribute7            => p_attribute7,
      p_attribute8            => p_attribute8,
      p_attribute9            => p_attribute9,
      p_attribute10           => p_attribute10,
      p_attribute11           => p_attribute11,
      p_attribute12           => p_attribute12,
      p_attribute13           => p_attribute13,
      p_attribute14           => p_attribute14,
      p_attribute15           => p_attribute15,
      p_attribute16           => p_attribute16,
      p_attribute17           => p_attribute17,
      p_attribute18           => p_attribute18,
      p_attribute19           => p_attribute19,
      p_attribute20           => p_attribute20,
      p_object_version_number => l_object_version_number
     );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_salary_survey'
        ,p_hook_type   => 'BP'
        );
  end;
  hr_utility.set_location(l_proc, 30);
  --
  -- Process Logic
  --
  per_pss_upd.upd(p_salary_survey_id      => l_salary_survey_id,
                  p_object_version_number => l_object_version_number,
                  p_survey_name           => p_survey_name,
--ras                  p_currency_code         => p_currency_code,
                  p_survey_type_code      => p_survey_type_code,
                  p_base_region           => p_base_region,
                  p_effective_date        => p_effective_date,
                  p_attribute_category    => p_attribute_category,
                  p_attribute1            => p_attribute1,
                  p_attribute2            => p_attribute2,
                  p_attribute3            => p_attribute3,
                  p_attribute4            => p_attribute4,
                  p_attribute5            => p_attribute5,
                  p_attribute6            => p_attribute6,
                  p_attribute7            => p_attribute7,
                  p_attribute8            => p_attribute8,
                  p_attribute9            => p_attribute9,
                  p_attribute10           => p_attribute10,
                  p_attribute11           => p_attribute11,
                  p_attribute12           => p_attribute12,
                  p_attribute13           => p_attribute13,
                  p_attribute14           => p_attribute14,
                  p_attribute15           => p_attribute15,
                  p_attribute16           => p_attribute16,
                  p_attribute17           => p_attribute17,
                  p_attribute18           => p_attribute18,
                  p_attribute19           => p_attribute19,
                  p_attribute20           => p_attribute20
                 );
  hr_utility.set_location(l_proc, 50);
  --
  -- Call After Process User Hook
  --
  begin
    hr_salary_survey_bk2.update_salary_survey_a
     (p_salary_survey_id      => l_salary_survey_id,
      p_object_version_number => l_object_version_number,
      p_survey_name           => p_survey_name,
--ras      p_currency_code         => p_currency_code,
      p_survey_type_code      => p_survey_type_code,
      p_base_region           => p_base_region,
      p_effective_date        => p_effective_date,
      p_attribute_category    => p_attribute_category,
      p_attribute1            => p_attribute1,
      p_attribute2            => p_attribute2,
      p_attribute3            => p_attribute3,
      p_attribute4            => p_attribute4,
      p_attribute5            => p_attribute5,
      p_attribute6            => p_attribute6,
      p_attribute7            => p_attribute7,
      p_attribute8            => p_attribute8,
      p_attribute9            => p_attribute9,
      p_attribute10           => p_attribute10,
      p_attribute11           => p_attribute11,
      p_attribute12           => p_attribute12,
      p_attribute13           => p_attribute13,
      p_attribute14           => p_attribute14,
      p_attribute15           => p_attribute15,
      p_attribute16           => p_attribute16,
      p_attribute17           => p_attribute17,
      p_attribute18           => p_attribute18,
      p_attribute19           => p_attribute19,
      p_attribute20           => p_attribute20
     );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_salary_survey'
        ,p_hook_type   => 'AP'
        );
  end;
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    --
    raise hr_api.validate_enabled;
    --
  end if;
  --
  -- Set all output arguments
  --
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_salary_survey;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    p_object_version_number  := l_temp_ovn;
    rollback to update_salary_survey;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    --
    raise;
    --
end update_salary_survey;

--
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_salary_survey >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_salary_survey
  (p_validate                      in     boolean  default false
  ,p_salary_survey_id              in     number
  ,p_object_version_number         in     number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'delete_salary_survey';
  --
  l_salary_survey_id      per_salary_surveys.salary_survey_id%TYPE;
  l_object_version_number per_salary_surveys.object_version_number%TYPE;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_salary_survey;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Call Before Process User Hook
  --
  --
  l_object_version_number := p_object_version_number;
  --
  --
  l_salary_survey_id      := p_salary_survey_id;
  --
  begin
    hr_salary_survey_bk3.delete_salary_survey_b
     (p_salary_survey_id      => l_salary_survey_id
     ,p_object_version_number => l_object_version_number
     );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_salary_survey'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  hr_utility.set_location(l_proc, 30);
  --
  -- Process Logic
  --
  per_pss_del.del(p_salary_survey_id      => l_salary_survey_id
                 ,p_object_version_number => l_object_version_number
                 );
  --
  hr_utility.set_location(l_proc, 50);
  --
  -- Call After Process User Hook
  --
  begin
    hr_salary_survey_bk3.delete_salary_survey_a
     (p_salary_survey_id      => l_salary_survey_id
     ,p_object_version_number => l_object_version_number
     );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_salary_survey'
        ,p_hook_type   => 'AP'
        );
  end;
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    --
    raise hr_api.validate_enabled;
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_salary_survey;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to delete_salary_survey;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    --
    raise;
    --
end delete_salary_survey;
--
end hr_salary_survey_api;

/
