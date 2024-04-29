--------------------------------------------------------
--  DDL for Package Body PQP_GDS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_GDS_API" as
/* $Header: pqgdsapi.pkb 120.0 2005/10/28 07:28 rvishwan noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  pqp_gds_api.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_duration_summary >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_duration_summary
 (p_validate                          IN  BOOLEAN DEFAULT FALSE
 ,p_date_start                        IN  DATE
 ,p_date_end                          IN  DATE
 ,p_assignment_id                     IN  NUMBER
 ,p_gap_absence_plan_id               IN  NUMBER
 ,p_duration_in_days                  IN  NUMBER
 ,p_duration_in_hours                 IN  NUMBER
 ,p_summary_type                      IN  VARCHAR2
 ,p_gap_level                         IN  VARCHAR2
 ,p_gap_duration_summary_id   OUT NOCOPY NUMBER
 ,p_object_version_number          OUT NOCOPY NUMBER
  ) is
  --
  -- Declare cursors and local variables
  --
  l_gap_duration_summary_id number;
  l_object_version_number        number;
  l_date_start                   date;
  l_date_end                     date;
  l_proc                varchar2(72) := g_package||'create_duration_summary';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_duration_summary;
  --
  -- Remember IN OUT parameter IN values
  --

  --
  -- Truncate the time portion from all IN date parameters
  --
   l_date_start := trunc(p_date_start);
   l_date_end   := trunc(p_date_end);

  --
  -- Call Before Process User Hook
  --

  begin
    pqp_gds_bk1.create_duration_summary_b
      (p_date_start                        =>  l_date_start
      ,p_gap_duration_summary_id      =>  l_gap_duration_summary_id
      ,p_date_end                          =>  l_date_end
      ,p_assignment_id                     =>  p_assignment_id
      ,p_gap_absence_plan_id               =>  p_gap_absence_plan_id
      ,p_duration_in_days                  =>  p_duration_in_days
      ,p_duration_in_hours                 =>  p_duration_in_hours
      ,p_summary_type                      =>  p_summary_type
      ,p_gap_level                         =>  p_gap_level
      ,p_object_version_number             =>  l_object_version_number
     );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_duration_summary'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --



  --
  -- Process Logic
  --
   pqp_gds_ins.ins
     (p_assignment_id                  =>     p_assignment_id
     ,p_gap_absence_plan_id            =>     p_gap_absence_plan_id
     ,p_summary_type                   =>     p_summary_type
     ,p_gap_level                      =>     p_gap_level
     ,p_duration_in_days               =>     p_duration_in_days
     ,p_date_start                     =>     l_date_start
     ,p_date_end                       =>     l_date_end
     ,p_duration_in_hours              =>     p_duration_in_hours
     ,p_gap_duration_summary_id   =>     l_gap_duration_summary_id
     ,p_object_version_number          =>     l_object_version_number
  );

  --
  -- Call After Process User Hook
  --
  begin
    pqp_gds_bk1.create_duration_summary_b
      (p_date_start                        =>  l_date_start
      ,p_gap_duration_summary_id      =>  l_gap_duration_summary_id
      ,p_date_end                          =>  l_date_end
      ,p_assignment_id                     =>  p_assignment_id
      ,p_gap_absence_plan_id               =>  p_gap_absence_plan_id
      ,p_duration_in_days                  =>  p_duration_in_days
      ,p_duration_in_hours                 =>  p_duration_in_hours
      ,p_summary_type                      =>  p_summary_type
      ,p_gap_level                         =>  p_gap_level
      ,p_object_version_number             =>  l_object_version_number
     );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_duration_summary'
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
  p_gap_duration_summary_id := l_gap_duration_summary_id;
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_duration_summary;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_gap_duration_summary_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_duration_summary;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_gap_duration_summary_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_duration_summary;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_duration_summary >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_duration_summary
 (p_validate                          IN  BOOLEAN DEFAULT FALSE
 ,p_gap_duration_summary_id      IN  NUMBER
 ,p_date_start                        IN  DATE
 ,p_date_end                          IN  DATE
 ,p_assignment_id                     IN  NUMBER
 ,p_gap_absence_plan_id               IN  NUMBER
 ,p_duration_in_days                  IN  NUMBER
 ,p_duration_in_hours                 IN  NUMBER
 ,p_summary_type                      IN  VARCHAR2
 ,p_gap_level                         IN  VARCHAR2
 ,p_object_version_number          IN OUT NOCOPY NUMBER
  ) is
  --
  -- Declare cursors and local variables
  --
  l_object_version_number  number;
  l_date_start                   date;
  l_date_end                     date;
  l_proc                varchar2(72) := g_package||'update_duration_summary';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_duration_summary;
  --
  -- Remember IN OUT parameter IN values
  --
  l_object_version_number := p_object_version_number;

  --
  -- Truncate the time portion from all IN date parameters
  --
   l_date_start := trunc(p_date_start);
   l_date_end   := trunc(p_date_end);


  --
  -- Call Before Process User Hook
  --
  begin
    pqp_gds_bk2.update_duration_summary_b
      (p_date_start                        =>  l_date_start
      ,p_gap_duration_summary_id      =>  p_gap_duration_summary_id
      ,p_date_end                          =>  l_date_end
      ,p_assignment_id                     =>  p_assignment_id
      ,p_gap_absence_plan_id               =>  p_gap_absence_plan_id
      ,p_duration_in_days                  =>  p_duration_in_days
      ,p_duration_in_hours                 =>  p_duration_in_hours
      ,p_summary_type                      =>  p_summary_type
      ,p_gap_level                         =>  p_gap_level
      ,p_object_version_number             =>  l_object_version_number
     );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_duration_summary'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --



  --
  -- Process Logic
  --
    pqp_gds_upd.upd
     (p_gap_duration_summary_id =>  p_gap_duration_summary_id
     ,p_object_version_number        =>  l_object_version_number
     ,p_assignment_id                =>  p_assignment_id
     ,p_gap_absence_plan_id          =>  p_gap_absence_plan_id
     ,p_summary_type                 =>  p_summary_type
     ,p_gap_level                    =>  p_gap_level
     ,p_duration_in_days             =>  p_duration_in_days
     ,p_date_start                   =>  l_date_start
     ,p_date_end                     =>  l_date_end
     ,p_duration_in_hours            =>  p_duration_in_hours
   );

  --
  -- Call After Process User Hook
  --
  begin
      pqp_gds_bk2.update_duration_summary_a
      (p_date_start                        =>  l_date_start
      ,p_gap_duration_summary_id      =>  p_gap_duration_summary_id
      ,p_date_end                          =>  l_date_end
      ,p_assignment_id                     =>  p_assignment_id
      ,p_gap_absence_plan_id               =>  p_gap_absence_plan_id
      ,p_duration_in_days                  =>  p_duration_in_days
      ,p_duration_in_hours                 =>  p_duration_in_hours
      ,p_summary_type                      =>  p_summary_type
      ,p_gap_level                         =>  p_gap_level
      ,p_object_version_number             =>  l_object_version_number
     );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_duration_summary'
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
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_duration_summary;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_duration_summary;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_duration_summary;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_duration_summary >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_duration_summary
  (p_validate                          IN  BOOLEAN DEFAULT FALSE
  ,p_gap_duration_summary_id     IN  NUMBER
  ,p_object_version_number             IN  NUMBER
  ) is
  --
  -- Declare cursors and local variables
  --
  l_object_version_number  number;
  l_proc                varchar2(72) := g_package||'delete_duration_summary';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_duration_summary;
  --
  -- Remember IN OUT parameter IN values
  --
  -- l_in_out_parameter := p_in_out_parameter;

  --
  -- Call Before Process User Hook
  --
  begin
    pqp_gds_bk3.delete_duration_summary_b
      (p_gap_duration_summary_id   =>     p_gap_duration_summary_id
      ,p_object_version_number          =>     p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_duration_summary'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --



  --
  -- Process Logic
  --
    pqp_gds_del.del
      (p_gap_duration_summary_id   =>  p_gap_duration_summary_id
      ,p_object_version_number          =>  p_object_version_number
      );
  --
  -- Call After Process User Hook
  --
  begin
    pqp_gds_bk3.delete_duration_summary_a
      (p_gap_duration_summary_id   =>     p_gap_duration_summary_id
      ,p_object_version_number          =>     p_object_version_number
      );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_duration_summary'
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
  -- p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_duration_summary;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    -- p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to delete_duration_summary;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    -- p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_duration_summary;
--
end pqp_gds_api;

/
