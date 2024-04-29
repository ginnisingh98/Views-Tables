--------------------------------------------------------
--  DDL for Package Body OTA_TMT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_TMT_API" as
/* $Header: ottmtapi.pkb 115.5 2002/11/26 17:03:17 hwinsor noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  OTA_TMT_API.';
--
-- ----------------------------------------------------------------------------
-- |-------------------------< CREATE_MEASURE >--------------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_measure
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_business_group_id             in     number
  ,p_tp_measurement_code           in     varchar2
  ,p_unit                          in     varchar2
  ,p_budget_level                  in     varchar2
  ,p_cost_level                    in     varchar2
  ,p_many_budget_values_flag       in     varchar2
  ,p_reporting_sequence            in     number   default null
  ,p_item_type_usage_id            in     number   default null
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
  ,p_attribute21                   in     varchar2 default null
  ,p_attribute22                   in     varchar2 default null
  ,p_attribute23                   in     varchar2 default null
  ,p_attribute24                   in     varchar2 default null
  ,p_attribute25                   in     varchar2 default null
  ,p_attribute26                   in     varchar2 default null
  ,p_attribute27                   in     varchar2 default null
  ,p_attribute28                   in     varchar2 default null
  ,p_attribute29                   in     varchar2 default null
  ,p_attribute30                   in     varchar2 default null
  ,p_tp_measurement_type_id           out nocopy number
  ,p_object_version_number            out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' Create Measure';
  l_tp_measurement_type_id  number;
  l_object_version_number   number;
  l_effective_date          date;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_measure;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  --
  -- Call Before Process User Hook
  --
  begin
    ota_tmt_api_bk1.create_measure_b
  (p_effective_date              => l_effective_date
  ,p_business_group_id           => p_business_group_id
  ,p_tp_measurement_code         => p_tp_measurement_code
  ,p_unit                        => p_unit
  ,p_budget_level                => p_budget_level
  ,p_cost_level                  => p_cost_level
  ,p_many_budget_values_flag     => p_many_budget_values_flag
  ,p_reporting_sequence          => p_reporting_sequence
  ,p_item_type_usage_id          => p_item_type_usage_id
  ,p_attribute_category          => p_attribute_category
  ,p_attribute1                  => p_attribute1
  ,p_attribute2                  => p_attribute2
  ,p_attribute3                  => p_attribute3
  ,p_attribute4                  => p_attribute4
  ,p_attribute5                  => p_attribute5
  ,p_attribute6                  => p_attribute6
  ,p_attribute7                  => p_attribute7
  ,p_attribute8                  => p_attribute8
  ,p_attribute9                  => p_attribute9
  ,p_attribute10                 => p_attribute10
  ,p_attribute11                 => p_attribute11
  ,p_attribute12                 => p_attribute12
  ,p_attribute13                 => p_attribute13
  ,p_attribute14                 => p_attribute14
  ,p_attribute15                 => p_attribute15
  ,p_attribute16                 => p_attribute16
  ,p_attribute17                 => p_attribute17
  ,p_attribute18                 => p_attribute18
  ,p_attribute19                 => p_attribute19
  ,p_attribute20                 => p_attribute20
  ,p_attribute21                 => p_attribute21
  ,p_attribute22                 => p_attribute22
  ,p_attribute23                 => p_attribute23
  ,p_attribute24                 => p_attribute24
  ,p_attribute25                 => p_attribute25
  ,p_attribute26                 => p_attribute26
  ,p_attribute27                 => p_attribute27
  ,p_attribute28                 => p_attribute28
  ,p_attribute29                 => p_attribute29
  ,p_attribute30                 => p_attribute30
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'Create_measure'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
  ota_tmt_ins.ins
  (p_effective_date                 => l_effective_date
  ,p_tp_measurement_code            => p_tp_measurement_code
  ,p_unit                           => p_unit
  ,p_budget_level                   => p_budget_level
  ,p_cost_level                     => p_cost_level
  ,p_many_budget_values_flag        => p_many_budget_values_flag
  ,p_business_group_id              => p_business_group_id
  ,p_reporting_sequence             => p_reporting_sequence
  ,p_item_type_usage_id             => p_item_type_usage_id
  ,p_attribute_category             => p_attribute_category
  ,p_attribute1                     => p_attribute1
  ,p_attribute2                     => p_attribute2
  ,p_attribute3                     => p_attribute3
  ,p_attribute4                     => p_attribute4
  ,p_attribute5                     => p_attribute5
  ,p_attribute6                     => p_attribute6
  ,p_attribute7                     => p_attribute7
  ,p_attribute8                     => p_attribute8
  ,p_attribute9                     => p_attribute9
  ,p_attribute10                    => p_attribute10
  ,p_attribute11                    => p_attribute11
  ,p_attribute12                    => p_attribute12
  ,p_attribute13                    => p_attribute13
  ,p_attribute14                    => p_attribute14
  ,p_attribute15                    => p_attribute15
  ,p_attribute16                    => p_attribute16
  ,p_attribute17                    => p_attribute17
  ,p_attribute18                    => p_attribute18
  ,p_attribute19                    => p_attribute19
  ,p_attribute20                    => p_attribute20
  ,p_attribute21                    => p_attribute21
  ,p_attribute22                    => p_attribute22
  ,p_attribute23                    => p_attribute23
  ,p_attribute24                    => p_attribute24
  ,p_attribute25                    => p_attribute25
  ,p_attribute26                    => p_attribute26
  ,p_attribute27                    => p_attribute27
  ,p_attribute28                    => p_attribute28
  ,p_attribute29                    => p_attribute29
  ,p_attribute30                    => p_attribute30
  ,p_tp_measurement_type_id         => l_tp_measurement_type_id
  ,p_object_version_number          => l_object_version_number);
  --
  -- Call After Process User Hook
  --
  begin
  ota_tmt_api_bk1.create_measure_a
  (p_effective_date              => l_effective_date
  ,p_business_group_id           => p_business_group_id
  ,p_tp_measurement_code         => p_tp_measurement_code
  ,p_unit                        => p_unit
  ,p_budget_level                => p_budget_level
  ,p_cost_level                  => p_cost_level
  ,p_many_budget_values_flag     => p_many_budget_values_flag
  ,p_reporting_sequence          => p_reporting_sequence
  ,p_item_type_usage_id          => p_item_type_usage_id
  ,p_attribute_category          => p_attribute_category
  ,p_attribute1                  => p_attribute1
  ,p_attribute2                  => p_attribute2
  ,p_attribute3                  => p_attribute3
  ,p_attribute4                  => p_attribute4
  ,p_attribute5                  => p_attribute5
  ,p_attribute6                  => p_attribute6
  ,p_attribute7                  => p_attribute7
  ,p_attribute8                  => p_attribute8
  ,p_attribute9                  => p_attribute9
  ,p_attribute10                 => p_attribute10
  ,p_attribute11                 => p_attribute11
  ,p_attribute12                 => p_attribute12
  ,p_attribute13                 => p_attribute13
  ,p_attribute14                 => p_attribute14
  ,p_attribute15                 => p_attribute15
  ,p_attribute16                 => p_attribute16
  ,p_attribute17                 => p_attribute17
  ,p_attribute18                 => p_attribute18
  ,p_attribute19                 => p_attribute19
  ,p_attribute20                 => p_attribute20
  ,p_attribute21                 => p_attribute21
  ,p_attribute22                 => p_attribute22
  ,p_attribute23                 => p_attribute23
  ,p_attribute24                 => p_attribute24
  ,p_attribute25                 => p_attribute25
  ,p_attribute26                 => p_attribute26
  ,p_attribute27                 => p_attribute27
  ,p_attribute28                 => p_attribute28
  ,p_attribute29                 => p_attribute29
  ,p_attribute30                 => p_attribute30
  ,p_tp_measurement_type_id      => l_tp_measurement_type_id
  ,p_object_version_number       => l_object_version_number
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_measure'
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
  -- Set all output arguments
  --
  p_tp_measurement_type_id := l_tp_measurement_type_id;
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_measure;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_tp_measurement_type_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_measure;
    p_tp_measurement_type_id := null;
    p_object_version_number := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_measure;
-- ----------------------------------------------------------------------------
-- |-------------------------< UPDATE_MEASURE >-------------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_measure
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_tp_measurement_type_id        in     number
  ,p_object_version_number         in out nocopy number
  ,p_unit                          in     varchar2 default hr_api.g_varchar2
  ,p_budget_level                  in     varchar2 default hr_api.g_varchar2
  ,p_cost_level                    in     varchar2 default hr_api.g_varchar2
  ,p_many_budget_values_flag       in     varchar2 default hr_api.g_varchar2
  ,p_reporting_sequence            in     number   default hr_api.g_number
  ,p_item_type_usage_id            in     number   default hr_api.g_number
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
  ,p_attribute21                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute22                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute23                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute24                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute25                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute26                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute27                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute28                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute29                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute30                   in     varchar2 default hr_api.g_varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' Update Measure';
  l_object_version_number   number       := p_object_version_number;
  l_effective_date          date;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_measure;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  --
  -- Call Before Process User Hook
  --
  begin
    ota_tmt_api_bk2.update_measure_b
  (p_effective_date              => l_effective_date
  ,p_tp_measurement_type_id      => p_tp_measurement_type_id
  ,p_object_version_number       => l_object_version_number
  ,p_unit                        => p_unit
  ,p_budget_level                => p_budget_level
  ,p_cost_level                  => p_cost_level
  ,p_many_budget_values_flag     => p_many_budget_values_flag
  ,p_reporting_sequence          => p_reporting_sequence
  ,p_item_type_usage_id          => p_item_type_usage_id
  ,p_attribute_category          => p_attribute_category
  ,p_attribute1                  => p_attribute1
  ,p_attribute2                  => p_attribute2
  ,p_attribute3                  => p_attribute3
  ,p_attribute4                  => p_attribute4
  ,p_attribute5                  => p_attribute5
  ,p_attribute6                  => p_attribute6
  ,p_attribute7                  => p_attribute7
  ,p_attribute8                  => p_attribute8
  ,p_attribute9                  => p_attribute9
  ,p_attribute10                 => p_attribute10
  ,p_attribute11                 => p_attribute11
  ,p_attribute12                 => p_attribute12
  ,p_attribute13                 => p_attribute13
  ,p_attribute14                 => p_attribute14
  ,p_attribute15                 => p_attribute15
  ,p_attribute16                 => p_attribute16
  ,p_attribute17                 => p_attribute17
  ,p_attribute18                 => p_attribute18
  ,p_attribute19                 => p_attribute19
  ,p_attribute20                 => p_attribute20
  ,p_attribute21                 => p_attribute21
  ,p_attribute22                 => p_attribute22
  ,p_attribute23                 => p_attribute23
  ,p_attribute24                 => p_attribute24
  ,p_attribute25                 => p_attribute25
  ,p_attribute26                 => p_attribute26
  ,p_attribute27                 => p_attribute27
  ,p_attribute28                 => p_attribute28
  ,p_attribute29                 => p_attribute29
  ,p_attribute30                 => p_attribute30
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'Update_measure'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
  ota_tmt_upd.upd
  (p_effective_date                 => l_effective_date
  ,p_tp_measurement_type_id         => p_tp_measurement_type_id
  ,p_object_version_number          => l_object_version_number
  ,p_unit                           => p_unit
  ,p_budget_level                   => p_budget_level
  ,p_cost_level                     => p_cost_level
  ,p_many_budget_values_flag        => p_many_budget_values_flag
  ,p_reporting_sequence             => p_reporting_sequence
  ,p_item_type_usage_id             => p_item_type_usage_id
  ,p_attribute_category             => p_attribute_category
  ,p_attribute1                     => p_attribute1
  ,p_attribute2                     => p_attribute2
  ,p_attribute3                     => p_attribute3
  ,p_attribute4                     => p_attribute4
  ,p_attribute5                     => p_attribute5
  ,p_attribute6                     => p_attribute6
  ,p_attribute7                     => p_attribute7
  ,p_attribute8                     => p_attribute8
  ,p_attribute9                     => p_attribute9
  ,p_attribute10                    => p_attribute10
  ,p_attribute11                    => p_attribute11
  ,p_attribute12                    => p_attribute12
  ,p_attribute13                    => p_attribute13
  ,p_attribute14                    => p_attribute14
  ,p_attribute15                    => p_attribute15
  ,p_attribute16                    => p_attribute16
  ,p_attribute17                    => p_attribute17
  ,p_attribute18                    => p_attribute18
  ,p_attribute19                    => p_attribute19
  ,p_attribute20                    => p_attribute20
  ,p_attribute21                    => p_attribute21
  ,p_attribute22                    => p_attribute22
  ,p_attribute23                    => p_attribute23
  ,p_attribute24                    => p_attribute24
  ,p_attribute25                    => p_attribute25
  ,p_attribute26                    => p_attribute26
  ,p_attribute27                    => p_attribute27
  ,p_attribute28                    => p_attribute28
  ,p_attribute29                    => p_attribute29
  ,p_attribute30                    => p_attribute30);
  --
  -- Call After Process User Hook
  --
  begin
  ota_tmt_api_bk2.update_measure_a
  (p_effective_date              => l_effective_date
  ,p_tp_measurement_type_id      => p_tp_measurement_type_id
  ,p_object_version_number       => l_object_version_number
  ,p_unit                        => p_unit
  ,p_budget_level                => p_budget_level
  ,p_cost_level                  => p_cost_level
  ,p_many_budget_values_flag     => p_many_budget_values_flag
  ,p_reporting_sequence          => p_reporting_sequence
  ,p_item_type_usage_id          => p_item_type_usage_id
  ,p_attribute_category          => p_attribute_category
  ,p_attribute1                  => p_attribute1
  ,p_attribute2                  => p_attribute2
  ,p_attribute3                  => p_attribute3
  ,p_attribute4                  => p_attribute4
  ,p_attribute5                  => p_attribute5
  ,p_attribute6                  => p_attribute6
  ,p_attribute7                  => p_attribute7
  ,p_attribute8                  => p_attribute8
  ,p_attribute9                  => p_attribute9
  ,p_attribute10                 => p_attribute10
  ,p_attribute11                 => p_attribute11
  ,p_attribute12                 => p_attribute12
  ,p_attribute13                 => p_attribute13
  ,p_attribute14                 => p_attribute14
  ,p_attribute15                 => p_attribute15
  ,p_attribute16                 => p_attribute16
  ,p_attribute17                 => p_attribute17
  ,p_attribute18                 => p_attribute18
  ,p_attribute19                 => p_attribute19
  ,p_attribute20                 => p_attribute20
  ,p_attribute21                 => p_attribute21
  ,p_attribute22                 => p_attribute22
  ,p_attribute23                 => p_attribute23
  ,p_attribute24                 => p_attribute24
  ,p_attribute25                 => p_attribute25
  ,p_attribute26                 => p_attribute26
  ,p_attribute27                 => p_attribute27
  ,p_attribute28                 => p_attribute28
  ,p_attribute29                 => p_attribute29
  ,p_attribute30                 => p_attribute30
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_measure'
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
  -- Set all output arguments
  --
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_measure;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_measure;
    p_object_version_number  := l_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_measure;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< DELETE_MEASURE >-------------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_measure
  (p_validate                      in     boolean  default false
  ,p_tp_measurement_type_id        in     number
  ,p_object_version_number         in     number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' Delete Measure';
  l_row_id                  varchar2(30);
  l_budget_version_id       number;
  l_budget_element_rowid    varchar2(30);
  l_exists                  varchar2(1);
  --
  cursor csr_get_budget_rowid is
    select pb.rowid row_id
    from   PER_BUDGETS pb
    where  ota_tmt_shd.g_old_rec.tp_measurement_code    = pb.unit
    and    ota_tmt_shd.g_old_rec.business_group_id      = pb.business_group_id
    and    ota_tmt_shd.g_old_rec.tp_measurement_type_id = p_tp_measurement_type_id
    and    pb.budget_type_code       = 'OTA_BUDGET';
  --
  cursor csr_get_budget_version_rowid is
    select pbv.rowid row_id
    from   PER_BUDGETS pb
          ,PER_BUDGET_VERSIONS pbv
    where  ota_tmt_shd.g_old_rec.tp_measurement_code    = pb.unit
    and    ota_tmt_shd.g_old_rec.business_group_id      = pb.business_group_id
    and    ota_tmt_shd.g_old_rec.tp_measurement_type_id = p_tp_measurement_type_id
    and    pb.budget_id                                 = pbv.budget_id
    and    pb.budget_type_code       = 'OTA_BUDGET';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_measure;
  --
  -- Truncate the time portion from all IN date parameters
  --
  --
  -- Call Before Process User Hook
  --
  begin
    ota_tmt_api_bk3.delete_measure_b
  (p_tp_measurement_type_id      => p_tp_measurement_type_id
  ,p_object_version_number       => p_object_version_number
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'Delete_measure'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
  hr_utility.set_location(' Step:'|| l_proc, 60);
  ota_tmt_del.del
  (p_tp_measurement_type_id         => p_tp_measurement_type_id
  ,p_object_version_number          => p_object_version_number
  );
  hr_utility.set_location(' Step:'|| l_proc, 65);
  --
  -- The business rules only allow deletion of the measure if no
  -- PER_BUDGET_VALUES records exist For the business group.
  -- An exception would have been raised by the chk_ procedures
  -- if this was the case, so we can proceed and delete the
  -- per_budget_elements records, then the per_budgets rcords
  --
  -- Delete the per_budget_version records (if any exist)
  --
  FOR l_loop IN csr_get_budget_version_rowid LOOP
    hr_utility.set_location(' Step:'|| l_proc, 70);
    PER_BUDGET_VERSION_RULES_PKG.Delete_Row(X_Rowid => l_loop.row_id);
  END LOOP;
  --
  -- Delete the per_budgets records (if any exist)
  --
  FOR l_loop IN csr_get_budget_rowid LOOP
    hr_utility.set_location(' Step:'|| l_proc, 80);
    per_budgets_pkg.delete_row(X_Rowid => l_loop.row_id);
  END LOOP;
  --
  -- Call After Process User Hook
  --
  begin
  ota_tmt_api_bk3.delete_measure_a
  (p_tp_measurement_type_id      => p_tp_measurement_type_id
  ,p_object_version_number       => p_object_version_number
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_measure'
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
  -- Set all output arguments
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 170);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_measure;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 180);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to delete_measure;
    hr_utility.set_location(' Leaving:'||l_proc, 190);
    raise;
end delete_measure;
--
end ota_tmt_api;

/
