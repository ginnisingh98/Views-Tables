--------------------------------------------------------
--  DDL for Package Body PER_BF_PAYROLL_RUNS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_BF_PAYROLL_RUNS_API" as
/* $Header: pebprapi.pkb 115.8 2002/12/02 13:06:45 apholt noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  PER_BF_PAYROLL_RUNS_API.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< <create_payroll_run> >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_payroll_run
  (p_validate                      in boolean          default false
  ,p_effective_date                in date
  ,p_business_group_id             in number
  ,p_payroll_id                    in number
  ,p_payroll_identifier            in varchar2
  ,p_period_start_date             in date             default null
  ,p_period_end_date               in date             default null
  ,p_processing_date               in date             default null
  ,p_bpr_attribute_category        in varchar2         default null
  ,p_bpr_attribute1                in varchar2         default null
  ,p_bpr_attribute2                in varchar2         default null
  ,p_bpr_attribute3                in varchar2         default null
  ,p_bpr_attribute4                in varchar2         default null
  ,p_bpr_attribute5                in varchar2         default null
  ,p_bpr_attribute6                in varchar2         default null
  ,p_bpr_attribute7                in varchar2         default null
  ,p_bpr_attribute8                in varchar2         default null
  ,p_bpr_attribute9                in varchar2         default null
  ,p_bpr_attribute10               in varchar2         default null
  ,p_bpr_attribute11               in varchar2         default null
  ,p_bpr_attribute12               in varchar2         default null
  ,p_bpr_attribute13               in varchar2         default null
  ,p_bpr_attribute14               in varchar2         default null
  ,p_bpr_attribute15               in varchar2         default null
  ,p_bpr_attribute16               in varchar2         default null
  ,p_bpr_attribute17               in varchar2         default null
  ,p_bpr_attribute18               in varchar2         default null
  ,p_bpr_attribute19               in varchar2         default null
  ,p_bpr_attribute20               in varchar2         default null
  ,p_bpr_attribute21               in varchar2         default null
  ,p_bpr_attribute22               in varchar2         default null
  ,p_bpr_attribute23               in varchar2         default null
  ,p_bpr_attribute24               in varchar2         default null
  ,p_bpr_attribute25               in varchar2         default null
  ,p_bpr_attribute26               in varchar2         default null
  ,p_bpr_attribute27               in varchar2         default null
  ,p_bpr_attribute28               in varchar2         default null
  ,p_bpr_attribute29               in varchar2         default null
  ,p_bpr_attribute30               in varchar2     default null
  --
  ,p_payroll_run_id                   out nocopy number
  ,p_object_version_number            out nocopy number
  )
IS
--
  --
  -- Declare cursors and local variables
  --
  l_payroll_run_id        PER_BF_PAYROLL_RUNS.PAYROLL_RUN_ID%TYPE;
  l_object_version_number PER_BF_PAYROLL_RUNS.OBJECT_VERSION_NUMBER%TYPE;
  --
  l_proc                varchar2(72) := g_package||'create_payroll_run';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_payroll_run;
  hr_utility.set_location(l_proc, 20);
  --
  -- Truncate the time portion from all IN date parameters
  --

  --
  -- Call Before Process User Hook
  --
  begin
    PER_BF_PAYROLL_RUNS_BK1.create_payroll_run_b
      (p_effective_date                => p_effective_date
      ,p_business_group_id             => p_business_group_id
      ,p_payroll_id                    => p_payroll_id
      ,p_payroll_identifier            => p_payroll_identifier
      ,p_period_start_date             => p_period_start_date
      ,p_period_end_date               => p_period_end_date
      ,p_processing_date               => p_processing_date
      ,p_bpr_attribute_category        => p_bpr_attribute_category
      ,p_bpr_attribute1                => p_bpr_attribute1
      ,p_bpr_attribute2                => p_bpr_attribute2
      ,p_bpr_attribute3                => p_bpr_attribute3
      ,p_bpr_attribute4                => p_bpr_attribute4
      ,p_bpr_attribute5                => p_bpr_attribute5
      ,p_bpr_attribute6                => p_bpr_attribute6
      ,p_bpr_attribute7                => p_bpr_attribute7
      ,p_bpr_attribute8                => p_bpr_attribute8
      ,p_bpr_attribute9                => p_bpr_attribute9
      ,p_bpr_attribute10               => p_bpr_attribute10
      ,p_bpr_attribute11               => p_bpr_attribute11
      ,p_bpr_attribute12               => p_bpr_attribute12
      ,p_bpr_attribute13               => p_bpr_attribute13
      ,p_bpr_attribute14               => p_bpr_attribute14
      ,p_bpr_attribute15               => p_bpr_attribute15
      ,p_bpr_attribute16               => p_bpr_attribute16
      ,p_bpr_attribute17               => p_bpr_attribute17
      ,p_bpr_attribute18               => p_bpr_attribute18
      ,p_bpr_attribute19               => p_bpr_attribute19
      ,p_bpr_attribute20               => p_bpr_attribute20
      ,p_bpr_attribute21               => p_bpr_attribute21
      ,p_bpr_attribute22               => p_bpr_attribute22
      ,p_bpr_attribute23               => p_bpr_attribute23
      ,p_bpr_attribute24               => p_bpr_attribute24
      ,p_bpr_attribute25               => p_bpr_attribute25
      ,p_bpr_attribute26               => p_bpr_attribute26
      ,p_bpr_attribute27               => p_bpr_attribute27
      ,p_bpr_attribute28               => p_bpr_attribute28
      ,p_bpr_attribute29               => p_bpr_attribute29
      ,p_bpr_attribute30               => p_bpr_attribute30
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_payroll_run'
        ,p_hook_type   => 'BP'
        );
  end;
  hr_utility.set_location(l_proc, 30);
  --
  -- Validation in addition to Row Handlers
  --
  hr_utility.set_location(l_proc, 40);
  --
  -- Process Logic
  --
  per_bpr_ins.ins
    (
     p_effective_date         => p_effective_date
    ,p_payroll_id             => p_payroll_id
    ,p_business_group_id      => p_business_group_id
    ,p_payroll_identifier     => p_payroll_identifier
    ,p_period_start_date      => p_period_start_date
    ,p_period_end_date        => p_period_end_date
    ,p_processing_date        => p_processing_date
    ,p_bpr_attribute_category     => p_bpr_attribute_category
    ,p_bpr_attribute1            => p_bpr_attribute1
    ,p_bpr_attribute2             => p_bpr_attribute2
    ,p_bpr_attribute3             => p_bpr_attribute3
    ,p_bpr_attribute4             => p_bpr_attribute4
    ,p_bpr_attribute5             => p_bpr_attribute5
    ,p_bpr_attribute6             => p_bpr_attribute6
    ,p_bpr_attribute7             => p_bpr_attribute7
    ,p_bpr_attribute8             => p_bpr_attribute8
    ,p_bpr_attribute9             => p_bpr_attribute9
    ,p_bpr_attribute10            => p_bpr_attribute10
    ,p_bpr_attribute11            => p_bpr_attribute11
    ,p_bpr_attribute12            => p_bpr_attribute12
    ,p_bpr_attribute13            => p_bpr_attribute13
    ,p_bpr_attribute14            => p_bpr_attribute14
    ,p_bpr_attribute15            => p_bpr_attribute15
    ,p_bpr_attribute16            => p_bpr_attribute16
    ,p_bpr_attribute17            => p_bpr_attribute17
    ,p_bpr_attribute18            => p_bpr_attribute18
    ,p_bpr_attribute19            => p_bpr_attribute19
    ,p_bpr_attribute20            => p_bpr_attribute20
    ,p_bpr_attribute21            => p_bpr_attribute21
    ,p_bpr_attribute22            => p_bpr_attribute22
    ,p_bpr_attribute23            => p_bpr_attribute23
    ,p_bpr_attribute24            => p_bpr_attribute24
    ,p_bpr_attribute25            => p_bpr_attribute25
    ,p_bpr_attribute26            => p_bpr_attribute26
    ,p_bpr_attribute27            => p_bpr_attribute27
    ,p_bpr_attribute28            => p_bpr_attribute28
    ,p_bpr_attribute29            => p_bpr_attribute29
    ,p_bpr_attribute30            => p_bpr_attribute30
    ,p_payroll_run_id         => l_payroll_run_id -- Out
    ,p_object_version_number  => l_object_version_number -- Out
    );
  --
  hr_utility.set_location(l_proc, 50);
  --
  -- Call After Process User Hook
  --
  begin
    PER_BF_PAYROLL_RUNS_BK1.create_payroll_run_a
      (p_effective_date                => p_effective_date
      ,p_business_group_id             => p_business_group_id
      ,p_payroll_id                    => p_payroll_id
      ,p_payroll_identifier            => p_payroll_identifier
      ,p_period_start_date             => p_period_start_date
      ,p_period_end_date               => p_period_end_date
      ,p_processing_date               => p_processing_date
      ,p_payroll_run_id                => l_payroll_run_id
      ,p_object_version_number         => l_object_version_number
      ,p_bpr_attribute_category        => p_bpr_attribute_category
      ,p_bpr_attribute1                => p_bpr_attribute1
      ,p_bpr_attribute2                => p_bpr_attribute2
      ,p_bpr_attribute3                => p_bpr_attribute3
      ,p_bpr_attribute4                => p_bpr_attribute4
      ,p_bpr_attribute5                => p_bpr_attribute5
      ,p_bpr_attribute6                => p_bpr_attribute6
      ,p_bpr_attribute7                => p_bpr_attribute7
      ,p_bpr_attribute8                => p_bpr_attribute8
      ,p_bpr_attribute9                => p_bpr_attribute9
      ,p_bpr_attribute10               => p_bpr_attribute10
      ,p_bpr_attribute11               => p_bpr_attribute11
      ,p_bpr_attribute12               => p_bpr_attribute12
      ,p_bpr_attribute13               => p_bpr_attribute13
      ,p_bpr_attribute14               => p_bpr_attribute14
      ,p_bpr_attribute15               => p_bpr_attribute15
      ,p_bpr_attribute16               => p_bpr_attribute16
      ,p_bpr_attribute17               => p_bpr_attribute17
      ,p_bpr_attribute18               => p_bpr_attribute18
      ,p_bpr_attribute19               => p_bpr_attribute19
      ,p_bpr_attribute20               => p_bpr_attribute20
      ,p_bpr_attribute21               => p_bpr_attribute21
      ,p_bpr_attribute22               => p_bpr_attribute22
      ,p_bpr_attribute23               => p_bpr_attribute23
      ,p_bpr_attribute24               => p_bpr_attribute24
      ,p_bpr_attribute25               => p_bpr_attribute25
      ,p_bpr_attribute26               => p_bpr_attribute26
      ,p_bpr_attribute27               => p_bpr_attribute27
      ,p_bpr_attribute28               => p_bpr_attribute28
      ,p_bpr_attribute29               => p_bpr_attribute29
      ,p_bpr_attribute30               => p_bpr_attribute30
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_payroll_run'
        ,p_hook_type   => 'AP'
        );
  end;
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
  p_payroll_run_id         := l_payroll_run_id;
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_payroll_run;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_payroll_run_id         := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_payroll_run;
    --set out NOCOPY variables
    p_payroll_run_id         := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_payroll_run;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_payroll_run >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_payroll_run
  (p_payroll_run_id                in number
  ,p_payroll_identifier            in varchar2         default hr_api.g_varchar2
  ,p_period_start_date             in date             default hr_api.g_date
  ,p_period_end_date               in date             default hr_api.g_date
  ,p_processing_date               in date             default hr_api.g_date
  ,p_bpr_attribute_category        in varchar2         default hr_api.g_varchar2
  ,p_bpr_attribute1                in varchar2         default hr_api.g_varchar2
  ,p_bpr_attribute2                in varchar2         default hr_api.g_varchar2
  ,p_bpr_attribute3                in varchar2         default hr_api.g_varchar2
  ,p_bpr_attribute4                in varchar2         default hr_api.g_varchar2
  ,p_bpr_attribute5                in varchar2         default hr_api.g_varchar2
  ,p_bpr_attribute6                in varchar2         default hr_api.g_varchar2
  ,p_bpr_attribute7                in varchar2         default hr_api.g_varchar2
  ,p_bpr_attribute8                in varchar2         default hr_api.g_varchar2
  ,p_bpr_attribute9                in varchar2         default hr_api.g_varchar2
  ,p_bpr_attribute10               in varchar2         default hr_api.g_varchar2
  ,p_bpr_attribute11               in varchar2         default hr_api.g_varchar2
  ,p_bpr_attribute12               in varchar2         default hr_api.g_varchar2
  ,p_bpr_attribute13               in varchar2         default hr_api.g_varchar2
  ,p_bpr_attribute14               in varchar2         default hr_api.g_varchar2
  ,p_bpr_attribute15               in varchar2         default hr_api.g_varchar2
  ,p_bpr_attribute16               in varchar2         default hr_api.g_varchar2
  ,p_bpr_attribute17               in varchar2         default hr_api.g_varchar2
  ,p_bpr_attribute18               in varchar2         default hr_api.g_varchar2
  ,p_bpr_attribute19               in varchar2         default hr_api.g_varchar2
  ,p_bpr_attribute20               in varchar2         default hr_api.g_varchar2
  ,p_bpr_attribute21               in varchar2         default hr_api.g_varchar2
  ,p_bpr_attribute22               in varchar2         default hr_api.g_varchar2
  ,p_bpr_attribute23               in varchar2         default hr_api.g_varchar2
  ,p_bpr_attribute24               in varchar2         default hr_api.g_varchar2
  ,p_bpr_attribute25               in varchar2         default hr_api.g_varchar2
  ,p_bpr_attribute26               in varchar2         default hr_api.g_varchar2
  ,p_bpr_attribute27               in varchar2         default hr_api.g_varchar2
  ,p_bpr_attribute28               in varchar2         default hr_api.g_varchar2
  ,p_bpr_attribute29               in varchar2         default hr_api.g_varchar2
  ,p_bpr_attribute30               in varchar2         default hr_api.g_varchar2
  ,p_validate                      in boolean          default false
  ,p_effective_date                in date
  ,p_object_version_number         in out nocopy number
  )
IS
--
  --
  -- Declare cursors and local variables
  --
  l_object_version_number   NUMBER;
  l_proc                varchar2(72) := g_package||'update_payroll_run';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_payroll_run;
  hr_utility.set_location(l_proc, 20);
  --
  -- Truncate the time portion from all IN date parameters
  --

  --
  -- Call Before Process User Hook
  --
  begin
    PER_BF_PAYROLL_RUNS_BK2.update_payroll_run_b
      (p_effective_date                => p_effective_date
      ,p_payroll_identifier            => p_payroll_identifier
      ,p_period_start_date             => p_period_start_date
      ,p_period_end_date               => p_period_end_date
      ,p_processing_date               => p_processing_date
      ,p_bpr_attribute_category        => p_bpr_attribute_category
      ,p_bpr_attribute1                => p_bpr_attribute1
      ,p_bpr_attribute2                => p_bpr_attribute2
      ,p_bpr_attribute3                => p_bpr_attribute3
      ,p_bpr_attribute4                => p_bpr_attribute4
      ,p_bpr_attribute5                => p_bpr_attribute5
      ,p_bpr_attribute6                => p_bpr_attribute6
      ,p_bpr_attribute7                => p_bpr_attribute7
      ,p_bpr_attribute8                => p_bpr_attribute8
      ,p_bpr_attribute9                => p_bpr_attribute9
      ,p_bpr_attribute10               => p_bpr_attribute10
      ,p_bpr_attribute11               => p_bpr_attribute11
      ,p_bpr_attribute12               => p_bpr_attribute12
      ,p_bpr_attribute13               => p_bpr_attribute13
      ,p_bpr_attribute14               => p_bpr_attribute14
      ,p_bpr_attribute15               => p_bpr_attribute15
      ,p_bpr_attribute16               => p_bpr_attribute16
      ,p_bpr_attribute17               => p_bpr_attribute17
      ,p_bpr_attribute18               => p_bpr_attribute18
      ,p_bpr_attribute19               => p_bpr_attribute19
      ,p_bpr_attribute20               => p_bpr_attribute20
      ,p_bpr_attribute21               => p_bpr_attribute21
      ,p_bpr_attribute22               => p_bpr_attribute22
      ,p_bpr_attribute23               => p_bpr_attribute23
      ,p_bpr_attribute24               => p_bpr_attribute24
      ,p_bpr_attribute25               => p_bpr_attribute25
      ,p_bpr_attribute26               => p_bpr_attribute26
      ,p_bpr_attribute27               => p_bpr_attribute27
      ,p_bpr_attribute28               => p_bpr_attribute28
      ,p_bpr_attribute29               => p_bpr_attribute29
      ,p_bpr_attribute30               => p_bpr_attribute30
      ,p_payroll_run_id                => p_payroll_run_id
      ,p_object_version_number         => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_payroll_run'
        ,p_hook_type   => 'BP'
        );
  end;
  hr_utility.set_location(l_proc, 30);
  --
  -- Validation in addition to Row Handlers
  --
  hr_utility.set_location(l_proc, 40);
  --
  -- Process Logic
  --
  l_object_version_number   := p_object_version_number;
  --
  per_bpr_upd.upd
    (
     p_effective_date         => p_effective_date
    ,p_payroll_run_id         => p_payroll_run_id
    ,p_payroll_identifier     => p_payroll_identifier
    ,p_period_start_date      => p_period_start_date
    ,p_period_end_date        => p_period_end_date
    ,p_processing_date        => p_processing_date
    ,p_bpr_attribute_category     => p_bpr_attribute_category
    ,p_bpr_attribute1            => p_bpr_attribute1
    ,p_bpr_attribute2             => p_bpr_attribute2
    ,p_bpr_attribute3             => p_bpr_attribute3
    ,p_bpr_attribute4             => p_bpr_attribute4
    ,p_bpr_attribute5             => p_bpr_attribute5
    ,p_bpr_attribute6             => p_bpr_attribute6
    ,p_bpr_attribute7             => p_bpr_attribute7
    ,p_bpr_attribute8             => p_bpr_attribute8
    ,p_bpr_attribute9             => p_bpr_attribute9
    ,p_bpr_attribute10            => p_bpr_attribute10
    ,p_bpr_attribute11            => p_bpr_attribute11
    ,p_bpr_attribute12            => p_bpr_attribute12
    ,p_bpr_attribute13            => p_bpr_attribute13
    ,p_bpr_attribute14            => p_bpr_attribute14
    ,p_bpr_attribute15            => p_bpr_attribute15
    ,p_bpr_attribute16            => p_bpr_attribute16
    ,p_bpr_attribute17            => p_bpr_attribute17
    ,p_bpr_attribute18            => p_bpr_attribute18
    ,p_bpr_attribute19            => p_bpr_attribute19
    ,p_bpr_attribute20            => p_bpr_attribute20
    ,p_bpr_attribute21            => p_bpr_attribute21
    ,p_bpr_attribute22            => p_bpr_attribute22
    ,p_bpr_attribute23            => p_bpr_attribute23
    ,p_bpr_attribute24            => p_bpr_attribute24
    ,p_bpr_attribute25            => p_bpr_attribute25
    ,p_bpr_attribute26            => p_bpr_attribute26
    ,p_bpr_attribute27            => p_bpr_attribute27
    ,p_bpr_attribute28            => p_bpr_attribute28
    ,p_bpr_attribute29            => p_bpr_attribute29
    ,p_bpr_attribute30            => p_bpr_attribute30
    ,p_object_version_number  => l_object_version_number -- Out
    );
  --
  hr_utility.set_location(l_proc, 50);
  --
  -- Call After Process User Hook
  --
  begin
    PER_BF_PAYROLL_RUNS_BK2.update_payroll_run_a
      (p_effective_date                => p_effective_date
      ,p_payroll_identifier            => p_payroll_identifier
      ,p_period_start_date             => p_period_start_date
      ,p_period_end_date               => p_period_end_date
      ,p_processing_date               => p_processing_date
      ,p_payroll_run_id                => p_payroll_run_id
      ,p_object_version_number         => p_object_version_number
      ,p_bpr_attribute_category        => p_bpr_attribute_category
      ,p_bpr_attribute1                => p_bpr_attribute1
      ,p_bpr_attribute2                => p_bpr_attribute2
      ,p_bpr_attribute3                => p_bpr_attribute3
      ,p_bpr_attribute4                => p_bpr_attribute4
      ,p_bpr_attribute5                => p_bpr_attribute5
      ,p_bpr_attribute6                => p_bpr_attribute6
      ,p_bpr_attribute7                => p_bpr_attribute7
      ,p_bpr_attribute8                => p_bpr_attribute8
      ,p_bpr_attribute9                => p_bpr_attribute9
      ,p_bpr_attribute10               => p_bpr_attribute10
      ,p_bpr_attribute11               => p_bpr_attribute11
      ,p_bpr_attribute12               => p_bpr_attribute12
      ,p_bpr_attribute13               => p_bpr_attribute13
      ,p_bpr_attribute14               => p_bpr_attribute14
      ,p_bpr_attribute15               => p_bpr_attribute15
      ,p_bpr_attribute16               => p_bpr_attribute16
      ,p_bpr_attribute17               => p_bpr_attribute17
      ,p_bpr_attribute18               => p_bpr_attribute18
      ,p_bpr_attribute19               => p_bpr_attribute19
      ,p_bpr_attribute20               => p_bpr_attribute20
      ,p_bpr_attribute21               => p_bpr_attribute21
      ,p_bpr_attribute22               => p_bpr_attribute22
      ,p_bpr_attribute23               => p_bpr_attribute23
      ,p_bpr_attribute24               => p_bpr_attribute24
      ,p_bpr_attribute25               => p_bpr_attribute25
      ,p_bpr_attribute26               => p_bpr_attribute26
      ,p_bpr_attribute27               => p_bpr_attribute27
      ,p_bpr_attribute28               => p_bpr_attribute28
      ,p_bpr_attribute29               => p_bpr_attribute29
      ,p_bpr_attribute30               => p_bpr_attribute30
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_payroll_run'
        ,p_hook_type   => 'AP'
        );
  end;
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
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_payroll_run;
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
    rollback to update_payroll_run;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_payroll_run;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_payroll_run >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_payroll_run
  (p_payroll_run_id                in number
  ,p_validate                      in boolean          default false
  ,p_object_version_number         in number
  )
IS
--
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'delete_payroll_run';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_payroll_run;
  hr_utility.set_location(l_proc, 20);
  --
  -- Truncate the time portion from all IN date parameters
  --

  --
  -- Call Before Process User Hook
  --
  begin
    PER_BF_PAYROLL_RUNS_BK3.delete_payroll_run_b
      (
       p_payroll_run_id                => p_payroll_run_id
      ,p_object_version_number         => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_payroll_run'
        ,p_hook_type   => 'BP'
        );
  end;
  hr_utility.set_location(l_proc, 30);
  --
  -- Validation in addition to Row Handlers
  --
  hr_utility.set_location(l_proc, 40);
  --
  -- Process Logic
  --
  per_bpr_del.del
    (
     p_payroll_run_id         => p_payroll_run_id
    ,p_object_version_number  => p_object_version_number
    );
  --
  hr_utility.set_location(l_proc, 50);
  --
  -- Call After Process User Hook
  --
  begin
    PER_BF_PAYROLL_RUNS_BK3.delete_payroll_run_a
      (
       p_payroll_run_id                => p_payroll_run_id
      ,p_object_version_number         => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_payroll_run'
        ,p_hook_type   => 'AP'
        );
  end;
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
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_payroll_run;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to delete_payroll_run;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_payroll_run;
end PER_BF_PAYROLL_RUNS_API;

/
