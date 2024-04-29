--------------------------------------------------------
--  DDL for Package Body PQH_FR_VALIDATION_PERIODS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_FR_VALIDATION_PERIODS_API" as
/* $Header: pqvlpapi.pkb 115.2 2002/12/05 00:31:28 rpasapul noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'PQH_FR_VALIDATION_PERIODS_API.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< Insert_Validation_Period >------------------------|
-- ----------------------------------------------------------------------------
--
procedure Insert_Validation_Period
  (p_effective_date               in     date
  ,p_validation_id                  in     number
  ,p_start_date                     in     date     default null
  ,p_end_date                       in     date     default null
  ,p_previous_employer_id           in     number   default null
  ,p_assignment_category	    in     varchar2 default null
  ,p_normal_hours                   in     number   default null
  ,p_frequency                      in     varchar2 default null
  ,p_period_years                   in     number   default null
  ,p_period_months                  in     number   default null
  ,p_period_days                    in     number   default null
  ,p_comments                       in     varchar2 default null
  ,p_validation_status              in     varchar2 default null
  ,p_validation_period_id              out nocopy number
  ,p_object_version_number             out nocopy number) is
  --
  -- Declare cursors and local variables
  --

  l_proc  varchar2(72)       := g_package||'Insert_Validation_Period';
  l_object_Version_Number    PQH_FR_VALIDATION_PERIODS.OBJECT_VERSION_NUMBER%TYPE;
  L_Effective_Date           Date;
  l_validation_period_id 		PQH_FR_VALIDATION_PERIODS.VALIDATION_PERIOD_ID%TYPE;


begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint Insert_Validation_Period;
  --
  -- Truncate the time portion from all IN date parameters
  --
     l_effective_date := Trunc(p_effective_Date);
  --
  -- Call Before Process User Hook
  --
  begin
   PQH_FR_VALIDATION_PERIODS_BK1.Insert_Validation_Period_b
   (p_effective_date               => l_effective_date
  ,p_validation_id                 => p_validation_id
  ,p_start_date                    => p_start_date
  ,p_end_date                      => p_end_date
  ,p_previous_employer_id          => p_previous_employer_id
  ,p_assignment_category	   => p_assignment_category
  ,p_normal_hours                  => p_normal_hours
  ,p_frequency                     => p_frequency
  ,p_period_years                  => p_period_years
  ,p_period_months                 => p_period_months
  ,p_period_days                   => p_period_days
  ,p_comments                      => p_comments
  ,p_validation_status             => p_validation_status
   );


  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQH_FR_VALIDATION_PERIODS_API.Insert_Validation_Period'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
     pqh_vlp_ins.ins
     (p_effective_date               => l_effective_date
  ,p_validation_period_id          => l_validation_period_id
  ,p_object_version_number         => l_object_version_number
  ,p_validation_id                 => p_validation_id
  ,p_start_date                    => p_start_date
  ,p_end_date                      => p_end_date
  ,p_previous_employer_id          => p_previous_employer_id
  ,p_assignment_category	   => p_assignment_category
  ,p_normal_hours                  => p_normal_hours
  ,p_frequency                     => p_frequency
  ,p_period_years                  => p_period_years
  ,p_period_months                 => p_period_months
  ,p_period_days                   => p_period_days
  ,p_comments                      => p_comments
  ,p_validation_status             => p_validation_status
     );

  --
  -- Call After Process User Hook
  --
  begin
     PQH_FR_VALIDATION_PERIODS_BK1.Insert_Validation_Period_a
     (p_effective_date               => l_effective_date
  ,p_validation_id                 => p_validation_id
  ,p_start_date                    => p_start_date
  ,p_end_date                      => p_end_date
  ,p_previous_employer_id          => p_previous_employer_id
  ,p_assignment_category	   => p_assignment_category
  ,p_normal_hours                  => p_normal_hours
  ,p_frequency                     => p_frequency
  ,p_period_years                  => p_period_years
  ,p_period_months                 => p_period_months
  ,p_period_days                   => p_period_days
  ,p_comments                      => p_comments
  ,p_validation_status             => p_validation_status);

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQH_FR_VALIDATION_PERIODS_API.Insert_Validation_Period'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
-- Removed p_validate from the generated code to facilitate
-- writing wrappers to selfservice easily.
--
--  if p_validate then
--    raise hr_api.validate_enabled;
--  end if;
  --
  -- Set all output arguments
  --
     p_validation_period_id := l_validation_period_id;
     p_object_version_number := l_object_version_number;


  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to Insert_Validation_Period;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);

  when others then
  p_validation_period_id := null;
  p_object_version_number := null;
    --
    -- A validation or unexpected error has occured
    --
    rollback to Insert_Validation_Period;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end Insert_Validation_Period;

--
-- ----------------------------------------------------------------------------
-- |--------------------------< Update_Validation_Period >--------------------------|
-- ----------------------------------------------------------------------------

procedure Update_Validation_Period
  (p_effective_date               in     date
  ,p_validation_period_id         in     number
  ,p_object_version_number        in out nocopy number
  ,p_validation_id                in     number    default hr_api.g_number
  ,p_start_date                   in     date      default hr_api.g_date
  ,p_end_date                     in     date      default hr_api.g_date
  ,p_previous_employer_id         in     number    default hr_api.g_number
  ,p_assignment_category	  in	 varchar2  default hr_api.g_varchar2
  ,p_normal_hours                 in     number    default hr_api.g_number
  ,p_frequency                    in     varchar2  default hr_api.g_varchar2
  ,p_period_years                 in     number    default hr_api.g_number
  ,p_period_months                in     number    default hr_api.g_number
  ,p_period_days                  in     number    default hr_api.g_number
  ,p_comments                     in     varchar2  default hr_api.g_varchar2
  ,p_validation_status            in     varchar2  default hr_api.g_varchar2) Is

  l_proc  varchar2(72)    := g_package||'Update_Validation_Period';
  l_object_Version_Number PQH_FR_VALIDATION_PERIODS.OBJECT_VERSION_NUMBER%TYPE := P_Object_version_Number;
  L_Effective_Date        Date;

Begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint Update_Validation_Period;
  --
  -- Truncate the time portion from all IN date parameters
  --
     l_effective_date := Trunc(p_effective_Date);
  --
  -- Call Before Process User Hook
  --
  begin

   PQH_FR_VALIDATION_PERIODS_BK2.Update_Validation_Period_b
  (p_effective_date               => l_effective_date
  ,p_validation_period_id          => p_validation_period_id
  ,p_object_version_number         => p_object_version_number
  ,p_validation_id                 => p_validation_id
  ,p_start_date                    => p_start_date
  ,p_end_date                      => p_end_date
  ,p_previous_employer_id          => p_previous_employer_id
  ,p_assignment_category	   => p_assignment_category
  ,p_normal_hours                  => p_normal_hours
  ,p_frequency                     => p_frequency
  ,p_period_years                  => p_period_years
  ,p_period_months                 => p_period_months
  ,p_period_days                   => p_period_days
  ,p_comments                      => p_comments
  ,p_validation_status             => p_validation_status
  );

 exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'Update_Validation_Period'
        ,p_hook_type   => 'BP'
        );
  end;

  pqh_vlp_upd.upd
  (p_effective_date               => l_effective_date
  ,p_validation_period_id          => p_validation_period_id
  ,p_object_version_number         => l_object_version_number
  ,p_validation_id                 => p_validation_id
  ,p_start_date                    => p_start_date
  ,p_end_date                      => p_end_date
  ,p_previous_employer_id          => p_previous_employer_id
  ,p_assignment_category	   => p_assignment_category
  ,p_normal_hours                  => p_normal_hours
  ,p_frequency                     => p_frequency
  ,p_period_years                  => p_period_years
  ,p_period_months                 => p_period_months
  ,p_period_days                   => p_period_days
  ,p_comments                      => p_comments
  ,p_validation_status             => p_validation_status);

--
--
  -- Call After Process User Hook
  --
  begin

   PQH_FR_VALIDATION_PERIODS_BK2.Update_Validation_Period_a
  (p_effective_date               => l_effective_date
  ,p_validation_period_id          => p_validation_period_id
  ,p_object_version_number         => l_object_version_number
  ,p_validation_id                 => p_validation_id
  ,p_start_date                    => p_start_date
  ,p_end_date                      => p_end_date
  ,p_previous_employer_id          => p_previous_employer_id
  ,p_assignment_category	   => p_assignment_category
  ,p_normal_hours                  => p_normal_hours
  ,p_frequency                     => p_frequency
  ,p_period_years                  => p_period_years
  ,p_period_months                 => p_period_months
  ,p_period_days                   => p_period_days
  ,p_comments                      => p_comments
  ,p_validation_status             => p_validation_status);

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'Update_Validation_Period'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
--  if p_validate then
--    raise hr_api.validate_enabled;
--  end if;
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
    rollback to Update_Validation_Period;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);

  when others then
  p_object_version_number := l_object_version_number;
    --
    -- A validation or unexpected error has occured
    --
    rollback to Update_Validation_Period;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end Update_Validation_Period;

--
-- ----------------------------------------------------------------------------
-- |-------------------< delete_Validation_period>------------------------------|
-- ----------------------------------------------------------------------------
procedure delete_Validation_period
  (p_validation_period_id                        in     number
  ,p_object_version_number                in     number
  ) Is   --

  -- Declare cursors and local variables
  --
  l_proc           varchar2(72) := g_package||'delete_Validation_period';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_Validation_period;
  --
  -- Call Before Process User Hook
  --
  begin
  PQH_FR_VALIDATION_PERIODS_BK3.Delete_Validation_Period_b
  (p_validation_period_id            => p_validation_period_id
  ,p_object_version_number   => p_object_version_number
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_Validation_period'
        ,p_hook_type   => 'BP');
  end;
  --
  -- Process Logic
  --
  pqh_vlp_del.del
    (
  p_validation_period_id            => p_validation_period_id
  ,p_object_version_number   => p_object_version_number
    );
  --
  -- Call After Process User Hook
  --
  begin

   PQH_FR_VALIDATION_PERIODS_BK3.Delete_Validation_Period_a
  (
  p_validation_period_id            => p_validation_period_id
  ,p_object_version_number   => p_object_version_number
  );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_Validation_period'
        ,p_hook_type   => 'AP');
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
--  if p_validate then
--    raise hr_api.validate_enabled;
--  end if;
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
    rollback to delete_Validation_period;
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
    rollback to delete_Validation_period;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_Validation_period;

end PQH_FR_VALIDATION_PERIODS_API;

/
