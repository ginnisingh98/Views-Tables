--------------------------------------------------------
--  DDL for Package Body HR_DE_LIABILITY_PREMIUMS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_DE_LIABILITY_PREMIUMS_API" as
/* $Header: hrlipapi.pkb 120.0 2005/05/31 01:16:39 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_de_liability_premiums_api.';
--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_premium >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_premium
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_organization_link_id          in     number
  ,p_std_percentage                in     number   default null
  ,p_calculation_method            in     varchar2 default null
  ,p_std_working_hours_per_year    in     number   default null
  ,p_max_remuneration              in     number   default null
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
  ,p_liability_premiums_id            out nocopy number
  ,p_object_version_number            out nocopy number
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'create_premium';
  l_liability_premiums_id hr_de_liability_premiums_f.liability_premiums_id%TYPE;
  l_object_version_number hr_de_liability_premiums_f.object_version_number%TYPE;
  l_effective_start_date  hr_de_liability_premiums_f.effective_start_date%TYPE;
  l_effective_end_date    hr_de_liability_premiums_f.effective_end_date%TYPE;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_premium;
  --
  -- Call Before Process User Hook
  --
  begin
    hr_de_liability_premiums_bk1.create_premium_b
      (p_effective_date             => trunc(p_effective_date)
      ,p_organization_link_id       => p_organization_link_id
      ,p_std_percentage             => p_std_percentage
      ,p_calculation_method         => p_calculation_method
      ,p_std_working_hours_per_year => p_std_working_hours_per_year
      ,p_max_remuneration           => p_max_remuneration
      ,p_attribute_category         => p_attribute_category
      ,p_attribute1                 => p_attribute1
      ,p_attribute2                 => p_attribute2
      ,p_attribute3                 => p_attribute3
      ,p_attribute4                 => p_attribute4
      ,p_attribute5                 => p_attribute5
      ,p_attribute6                 => p_attribute6
      ,p_attribute7                 => p_attribute7
      ,p_attribute8                 => p_attribute8
      ,p_attribute9                 => p_attribute9
      ,p_attribute10                => p_attribute1
      ,p_attribute11                => p_attribute11
      ,p_attribute12                => p_attribute12
      ,p_attribute13                => p_attribute13
      ,p_attribute14                => p_attribute14
      ,p_attribute15                => p_attribute15
      ,p_attribute16                => p_attribute16
      ,p_attribute17                => p_attribute17
      ,p_attribute18                => p_attribute18
      ,p_attribute19                => p_attribute19
      ,p_attribute20                => p_attribute20);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_premium'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
  hr_lip_ins.ins
    (p_effective_date             => trunc(p_effective_date)
    ,p_organization_link_id       => p_organization_link_id
    ,p_std_percentage             => p_std_percentage
    ,p_calculation_method         => p_calculation_method
    ,p_std_working_hours_per_year => p_std_working_hours_per_year
    ,p_max_remuneration           => p_max_remuneration
    ,p_attribute_category         => p_attribute_category
    ,p_attribute1                 => p_attribute1
    ,p_attribute2                 => p_attribute2
    ,p_attribute3                 => p_attribute3
    ,p_attribute4                 => p_attribute4
    ,p_attribute5                 => p_attribute5
    ,p_attribute6                 => p_attribute6
    ,p_attribute7                 => p_attribute7
    ,p_attribute8                 => p_attribute8
    ,p_attribute9                 => p_attribute9
    ,p_attribute10                => p_attribute10
    ,p_attribute11                => p_attribute11
    ,p_attribute12                => p_attribute12
    ,p_attribute13                => p_attribute13
    ,p_attribute14                => p_attribute14
    ,p_attribute15                => p_attribute15
    ,p_attribute16                => p_attribute16
    ,p_attribute17                => p_attribute17
    ,p_attribute18                => p_attribute18
    ,p_attribute19                => p_attribute19
    ,p_attribute20                => p_attribute20
    ,p_liability_premiums_id      => l_liability_premiums_id
    ,p_object_version_number      => l_object_version_number
    ,p_effective_start_date       => l_effective_start_date
    ,p_effective_end_date         => l_effective_end_date);
  --
  -- Call After Process User Hook
  --
  begin
    hr_de_liability_premiums_bk1.create_premium_a
      (p_effective_date             => trunc(p_effective_date)
      ,p_organization_link_id       => p_organization_link_id
      ,p_std_percentage             => p_std_percentage
      ,p_calculation_method         => p_calculation_method
      ,p_std_working_hours_per_year => p_std_working_hours_per_year
      ,p_max_remuneration           => p_max_remuneration
      ,p_attribute_category         => p_attribute_category
      ,p_attribute1                 => p_attribute1
      ,p_attribute2                 => p_attribute2
      ,p_attribute3                 => p_attribute3
      ,p_attribute4                 => p_attribute4
      ,p_attribute5                 => p_attribute5
      ,p_attribute6                 => p_attribute6
      ,p_attribute7                 => p_attribute7
      ,p_attribute8                 => p_attribute8
      ,p_attribute9                 => p_attribute9
      ,p_attribute10                => p_attribute1
      ,p_attribute11                => p_attribute11
      ,p_attribute12                => p_attribute12
      ,p_attribute13                => p_attribute13
      ,p_attribute14                => p_attribute14
      ,p_attribute15                => p_attribute15
      ,p_attribute16                => p_attribute16
      ,p_attribute17                => p_attribute17
      ,p_attribute18                => p_attribute18
      ,p_attribute19                => p_attribute19
      ,p_attribute20                => p_attribute20
      ,p_liability_premiums_id      => l_liability_premiums_id
      ,p_object_version_number      => l_object_version_number
      ,p_effective_start_date       => l_effective_start_date
      ,p_effective_end_date         => l_effective_end_date);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_premium'
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
  p_liability_premiums_id := l_liability_premiums_id;
  p_object_version_number := l_object_version_number;
  p_effective_start_date  := l_effective_start_date;
  p_effective_end_date    := l_effective_end_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_premium;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_liability_premiums_id := null;
    p_object_version_number := null;
    p_effective_start_date  := null;
    p_effective_end_date    := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_premium;
    -- Set OUT parameters.
    p_liability_premiums_id := null;
    p_object_version_number := null;
    p_effective_start_date  := null;
    p_effective_end_date    := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_premium;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< update_premium >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_premium
  (p_validate                     in     boolean  default false
  ,p_effective_date               in     date
  ,p_datetrack_mode               in     varchar2
  ,p_liability_premiums_id        in     number
  ,p_std_percentage               in     number    default hr_api.g_number
  ,p_calculation_method           in     varchar2  default hr_api.g_varchar2
  ,p_std_working_hours_per_year   in     number    default hr_api.g_number
  ,p_max_remuneration             in     number    default hr_api.g_number
  ,p_attribute_category           in     varchar2  default hr_api.g_varchar2
  ,p_attribute1                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute2                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute3                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute4                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute5                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute6                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute7                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute8                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute9                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute10                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute11                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute12                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute13                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute14                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute15                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute16                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute17                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute18                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute19                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute20                  in     varchar2  default hr_api.g_varchar2
  ,p_object_version_number        in out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'update_premium';
  l_liability_premiums_id hr_de_liability_premiums_f.liability_premiums_id%TYPE;
  l_object_version_number hr_de_liability_premiums_f.object_version_number%TYPE := p_object_version_number;
  l_effective_start_date  hr_de_liability_premiums_f.effective_start_date%TYPE;
  l_effective_end_date    hr_de_liability_premiums_f.effective_end_date%TYPE;
  l_organization_link_id_o number;
  l_temp_ovn   number := p_object_version_number;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_premium;
  --
  -- Call Before Process User Hook
  --
  begin
    hr_de_liability_premiums_bk2.update_premium_b
      (p_effective_date             => trunc(p_effective_date)
      ,p_datetrack_mode             => p_datetrack_mode
      ,p_liability_premiums_id      => p_liability_premiums_id
      ,p_organization_link_id_o     => l_organization_link_id_o
      ,p_std_percentage             => p_std_percentage
      ,p_calculation_method         => p_calculation_method
      ,p_std_working_hours_per_year => p_std_working_hours_per_year
      ,p_max_remuneration           => p_max_remuneration
      ,p_attribute_category         => p_attribute_category
      ,p_attribute1                 => p_attribute1
      ,p_attribute2                 => p_attribute2
      ,p_attribute3                 => p_attribute3
      ,p_attribute4                 => p_attribute4
      ,p_attribute5                 => p_attribute5
      ,p_attribute6                 => p_attribute6
      ,p_attribute7                 => p_attribute7
      ,p_attribute8                 => p_attribute8
      ,p_attribute9                 => p_attribute9
      ,p_attribute10                => p_attribute1
      ,p_attribute11                => p_attribute11
      ,p_attribute12                => p_attribute12
      ,p_attribute13                => p_attribute13
      ,p_attribute14                => p_attribute14
      ,p_attribute15                => p_attribute15
      ,p_attribute16                => p_attribute16
      ,p_attribute17                => p_attribute17
      ,p_attribute18                => p_attribute18
      ,p_attribute19                => p_attribute19
      ,p_attribute20                => p_attribute20
      ,p_object_version_number      => l_object_version_number);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_premium'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
  hr_lip_upd.upd
    (p_effective_date             => trunc(p_effective_date)
    ,p_datetrack_mode             => p_datetrack_mode
    ,p_liability_premiums_id      => p_liability_premiums_id
    ,p_std_percentage             => p_std_percentage
    ,p_calculation_method         => p_calculation_method
    ,p_std_working_hours_per_year => p_std_working_hours_per_year
    ,p_max_remuneration           => p_max_remuneration
    ,p_attribute_category         => p_attribute_category
    ,p_attribute1                 => p_attribute1
    ,p_attribute2                 => p_attribute2
    ,p_attribute3                 => p_attribute3
    ,p_attribute4                 => p_attribute4
    ,p_attribute5                 => p_attribute5
    ,p_attribute6                 => p_attribute6
    ,p_attribute7                 => p_attribute7
    ,p_attribute8                 => p_attribute8
    ,p_attribute9                 => p_attribute9
    ,p_attribute10                => p_attribute10
    ,p_attribute11                => p_attribute11
    ,p_attribute12                => p_attribute12
    ,p_attribute13                => p_attribute13
    ,p_attribute14                => p_attribute14
    ,p_attribute15                => p_attribute15
    ,p_attribute16                => p_attribute16
    ,p_attribute17                => p_attribute17
    ,p_attribute18                => p_attribute18
    ,p_attribute19                => p_attribute19
    ,p_attribute20                => p_attribute20
    ,p_object_version_number      => l_object_version_number
    ,p_effective_start_date       => l_effective_start_date
    ,p_effective_end_date         => l_effective_end_date);
  --
  -- Call After Process User Hook
  --
  begin
    hr_de_liability_premiums_bk2.update_premium_a
      (p_effective_date             => trunc(p_effective_date)
      ,p_datetrack_mode             => p_datetrack_mode
      ,p_liability_premiums_id      => p_liability_premiums_id
      ,p_organization_link_id_o     => l_organization_link_id_o
      ,p_std_percentage             => p_std_percentage
      ,p_calculation_method         => p_calculation_method
      ,p_std_working_hours_per_year => p_std_working_hours_per_year
      ,p_max_remuneration           => p_max_remuneration
      ,p_attribute_category         => p_attribute_category
      ,p_attribute1                 => p_attribute1
      ,p_attribute2                 => p_attribute2
      ,p_attribute3                 => p_attribute3
      ,p_attribute4                 => p_attribute4
      ,p_attribute5                 => p_attribute5
      ,p_attribute6                 => p_attribute6
      ,p_attribute7                 => p_attribute7
      ,p_attribute8                 => p_attribute8
      ,p_attribute9                 => p_attribute9
      ,p_attribute10                => p_attribute1
      ,p_attribute11                => p_attribute11
      ,p_attribute12                => p_attribute12
      ,p_attribute13                => p_attribute13
      ,p_attribute14                => p_attribute14
      ,p_attribute15                => p_attribute15
      ,p_attribute16                => p_attribute16
      ,p_attribute17                => p_attribute17
      ,p_attribute18                => p_attribute18
      ,p_attribute19                => p_attribute19
      ,p_attribute20                => p_attribute20
      ,p_object_version_number      => l_object_version_number
      ,p_effective_start_date       => l_effective_start_date
      ,p_effective_end_date         => l_effective_end_date);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'after_premium'
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
  p_object_version_number := l_object_version_number;
  p_effective_start_date  := l_effective_start_date;
  p_effective_end_date    := l_effective_end_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_premium;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number := null;
    p_effective_start_date  := null;
    p_effective_end_date    := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_premium;
    -- Reset IN OUT and set OUT parameters.
    p_object_version_number := l_temp_ovn;
    p_effective_start_date  := null;
    p_effective_end_date    := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_premium;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< delete_premium >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_premium
  (p_validate                     in     boolean  default false
  ,p_effective_date               in     date
  ,p_datetrack_mode               in     varchar2
  ,p_liability_premiums_id        in     number
  ,p_object_version_number        in out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'delete_premium';
  l_object_version_number hr_de_liability_premiums_f.object_version_number%TYPE := p_object_version_number;
  l_effective_start_date  hr_de_liability_premiums_f.effective_start_date%TYPE;
  l_effective_end_date    hr_de_liability_premiums_f.effective_end_date%TYPE;
  l_organization_link_id_o   number;
  l_temp_ovn   number := p_object_version_number;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_premium;
  --
  -- Call Before Process User Hook
  --
  begin
    hr_de_liability_premiums_bk3.delete_premium_b
      (p_effective_date             => trunc(p_effective_date)
      ,p_datetrack_mode             => p_datetrack_mode
      ,p_liability_premiums_id      => p_liability_premiums_id
      ,p_organization_link_id_o     => l_organization_link_id_o
      ,p_object_version_number      => l_object_version_number);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_premium'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
  hr_lip_del.del
    (p_effective_date             => trunc(p_effective_date)
    ,p_datetrack_mode             => p_datetrack_mode
    ,p_liability_premiums_id      => p_liability_premiums_id
    ,p_object_version_number      => l_object_version_number
    ,p_effective_start_date       => l_effective_start_date
    ,p_effective_end_date         => l_effective_end_date);
  --
  -- Call After Process User Hook
  --
  begin
    hr_de_liability_premiums_bk3.delete_premium_a
      (p_effective_date             => trunc(p_effective_date)
      ,p_datetrack_mode             => p_datetrack_mode
      ,p_liability_premiums_id      => p_liability_premiums_id
      ,p_organization_link_id_o     => l_organization_link_id_o
      ,p_object_version_number      => l_object_version_number
      ,p_effective_start_date       => l_effective_start_date
      ,p_effective_end_date         => l_effective_end_date);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_premium'
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
  p_object_version_number := l_object_version_number;
  p_effective_start_date  := l_effective_start_date;
  p_effective_end_date    := l_effective_end_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_premium;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number := null;
    p_effective_start_date  := null;
    p_effective_end_date    := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to delete_premium;
    -- Reset IN OUT and set OUT parameters.
    p_object_version_number := l_temp_ovn;
    p_effective_start_date  := null;
    p_effective_end_date    := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_premium;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (p_effective_date                   in date
  ,p_datetrack_mode                   in varchar2
  ,p_liability_premiums_id            in number
  ,p_object_version_number            in number
  ,p_validation_start_date            out nocopy date
  ,p_validation_end_date              out nocopy date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'lck';
  l_validation_start_date date;
  l_validation_end_date   date;
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Lock the record.
  --
  hr_lip_shd.lck
    (p_effective_date        => trunc(p_effective_date)
    ,p_datetrack_mode        => p_datetrack_mode
    ,p_liability_premiums_id => p_liability_premiums_id
    ,p_object_version_number => p_object_version_number
    ,p_validation_start_date => l_validation_start_date
    ,p_validation_end_date   => l_validation_end_date);
  --
  -- Set all output arguments
  --
  p_validation_start_date := l_validation_start_date;
  p_validation_end_date   := l_validation_end_date;
  --
  hr_utility.set_location('Exiting:'|| l_proc, 70);
  --
end lck;
--
end hr_de_liability_premiums_api;

/
