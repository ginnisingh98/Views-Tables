--------------------------------------------------------
--  DDL for Package Body HR_NL_ABSENCE_ACTION_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_NL_ABSENCE_ACTION_API" as
/* $Header: penaaapi.pkb 115.8 2004/04/19 08:13:40 sgajula noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_nl_absence_action_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< <create_absence_action> >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure CREATE_ABSENCE_ACTION
  (p_validate                      in     boolean
  ,p_absence_attendance_id         in     number
  ,p_expected_date                 in     date
  ,p_description                   in     varchar2
  ,p_actual_start_date             in     date
  ,p_actual_end_date               in     date
  ,p_holder                        in     varchar2
  ,p_comments                      in     varchar2
  ,p_document_file_name            in     varchar2
  ,p_absence_action_id             out    nocopy  number
  ,p_object_version_number         out    nocopy  number
  ,p_enabled                       in     varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'create_absence_action';
  l_expected_date       date;
  l_actual_start_date   date;
  l_actual_end_date     date;
  --
  -- Declare Out Parameters
  --
  l_absence_action_id        number;
  l_last_updated_by           number;
  l_object_version_number    number;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_absence_action;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_expected_date       := trunc(p_expected_date);
  l_actual_start_date   := trunc(p_actual_start_date);
  l_actual_end_date     := trunc(p_actual_end_date);
  --
  --
  -- Call Before Process User Hook
  --
  begin
    hr_nl_absence_action_bk1.create_absence_action_b
      (p_absence_attendance_id         =>     p_absence_attendance_id
      ,p_expected_date                 =>     l_expected_date
      ,p_description                   =>     p_description
      ,p_actual_start_date             =>     l_actual_start_date
      ,p_actual_end_date               =>     l_actual_end_date
      ,p_holder                        =>     p_holder
      ,p_comments                      =>     p_comments
      ,p_document_file_name            =>     p_document_file_name
      ,p_enabled                       =>     p_enabled
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_ABSENCE_ACTION'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  hr_utility.set_location('Entering:'|| l_proc, 20);
  --
  -- Insert Absence Action
  --
  per_naa_ins.ins
  (p_absence_attendance_id        => p_absence_attendance_id
  ,p_expected_date                => l_expected_date
  ,p_description                  => p_description
  ,p_actual_start_date            => l_actual_start_date
  ,p_actual_end_date              => l_actual_end_date
  ,p_holder                       => p_holder
  ,p_comments                     => p_comments
  ,p_document_file_name           => p_document_file_name
  ,p_last_updated_by               => l_last_updated_by
  ,p_absence_action_id            => l_absence_action_id
  ,p_object_version_number        => l_object_version_number
  ,p_enabled                      => p_enabled
  );

  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
  --
  -- Call After Process User Hook
  --
  begin
    hr_nl_absence_action_bk1.create_absence_action_a
      (p_absence_attendance_id         =>     p_absence_attendance_id
      ,p_absence_action_id             =>     l_absence_action_id
      ,p_expected_date                 =>     l_expected_date
      ,p_description                   =>     p_description
      ,p_actual_start_date             =>     l_actual_start_date
      ,p_actual_end_date               =>     l_actual_end_date
      ,p_holder                        =>     p_holder
      ,p_comments                      =>     p_comments
      ,p_document_file_name            =>     p_document_file_name
      ,p_object_version_number         =>     l_object_version_number
      ,p_enabled                       =>     p_enabled
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'HR_NL_ABSENCE_ACTION_BK1'
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
  p_absence_action_id      := l_absence_action_id;
  p_object_version_number  := l_object_version_number;
  --  p_some_warning           := <local_var_set_in_process_logic>;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to CREATE_ABSENCE_ACTION;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_absence_action_id      := null;
    p_object_version_number  := null;
    -- p_some_warning           := <local_var_set_in_process_logic>;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to CREATE_ABSENCE_ACTION;
    --
    -- set in out parameters and set out parameters
    --
    p_absence_action_id      := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end CREATE_ABSENCE_ACTION;
--
-- ----------------------------------------------------------------------------
-- |------------------------< <update_absence_action> >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure UPDATE_ABSENCE_ACTION
  (p_validate                      in     boolean
  ,p_absence_attendance_id         in     number
  ,p_absence_action_id             in     number
  ,p_object_version_number         in out nocopy number
  ,p_expected_date                 in     date
  ,p_description                   in     varchar2
  ,p_actual_start_date             in     date
  ,p_actual_end_date               in     date
  ,p_holder                        in     varchar2
  ,p_comments                      in     varchar2
  ,p_document_file_name            in     varchar2
  ,p_enabled                       in     varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'update_absence_action';
  l_effective_date      date;
  l_expected_date       date;
  l_actual_start_date   date;
  l_actual_end_date     date;
  l_last_updated_by      number;
  --
  -- Declare Out Parameters
  --
  l_object_version_number    number := p_object_version_number;
  l_ovn number := p_object_version_number;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_absence_action;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_expected_date       := trunc(p_expected_date);
  l_actual_start_date   := trunc(p_actual_start_date);
  l_actual_end_date     := trunc(p_actual_end_date);
  --
  --
  -- Call Before Process User Hook
  --
  begin
    hr_nl_absence_action_bk2.update_absence_action_b
      (p_absence_attendance_id         =>     p_absence_attendance_id
      ,p_absence_action_id             =>     p_absence_action_id
      ,p_expected_date                 =>     l_expected_date
      ,p_description                   =>     p_description
      ,p_actual_start_date             =>     l_actual_start_date
      ,p_actual_end_date               =>     l_actual_end_date
      ,p_holder                        =>     p_holder
      ,p_comments                      =>     p_comments
      ,p_document_file_name            =>     p_document_file_name
      ,p_object_version_number         =>     p_object_version_number
      ,p_enabled                       =>     p_enabled
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_ABSENCE_ACTION'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  hr_utility.set_location('Entering:'|| l_proc, 20);
  --
  -- Update Absence Action
  --
  per_naa_upd.upd
  (p_absence_attendance_id        => p_absence_attendance_id
  ,p_expected_date                => l_expected_date
  ,p_description                  => p_description
  ,p_actual_start_date            => l_actual_start_date
  ,p_actual_end_date              => l_actual_end_date
  ,p_holder                       => p_holder
  ,p_comments                     => p_comments
  ,p_document_file_name           => p_document_file_name
  ,p_last_updated_by               => l_last_updated_by
  ,p_absence_action_id            => p_absence_action_id
  ,p_object_version_number        => l_object_version_number
  ,p_enabled                      => p_enabled
  );

  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
  --
  -- Call After Process User Hook
  --
  begin
    hr_nl_absence_action_bk2.update_absence_action_a
      (p_absence_attendance_id         =>     p_absence_attendance_id
      ,p_absence_action_id             =>     p_absence_action_id
      ,p_expected_date                 =>     l_expected_date
      ,p_description                   =>     p_description
      ,p_actual_start_date             =>     l_actual_start_date
      ,p_actual_end_date               =>     l_actual_end_date
      ,p_holder                        =>     p_holder
      ,p_comments                      =>     p_comments
      ,p_document_file_name            =>     p_document_file_name
      ,p_object_version_number         =>     l_object_version_number
      ,p_enabled                       =>     p_enabled
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'HR_NL_ABSENCE_ACTION_BK2'
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
  --  p_some_warning           := <local_var_set_in_process_logic>;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to UPDATE_ABSENCE_ACTION;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := null;
    -- p_some_warning           := <local_var_set_in_process_logic>;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to UPDATE_ABSENCE_ACTION;
    --
    -- set in out parameters and set out parameters
    --
    p_object_version_number := l_ovn;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end UPDATE_ABSENCE_ACTION;
--
-- ----------------------------------------------------------------------------
-- |------------------------< <delete_absence_action> >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure DELETE_ABSENCE_ACTION
  (p_validate                      in      boolean
  ,p_absence_action_id             in      number
  ,p_object_version_number         in      number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'delete_absence_action';
  --
  -- Declare Out Parameters
  --
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_absence_action;
  --
  -- Truncate the time portion from all IN date parameters
  --
  -- Call Before Process User Hook
  --
  begin
    hr_nl_absence_action_bk3.delete_absence_action_b
      (p_absence_action_id             =>     p_absence_action_id
      ,p_object_version_number         =>     p_object_version_number
       );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_ABSENCE_ACTION'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  hr_utility.set_location('Entering:'|| l_proc, 20);
  --
  -- Delete Absence Action
  --
  per_naa_del.del
  (p_absence_action_id            => p_absence_action_id
  ,p_object_version_number        => p_object_version_number
  );

  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
  --
  -- Call After Process User Hook
  --
  begin
    hr_nl_absence_action_bk3.delete_absence_action_a
      (p_absence_action_id             =>     p_absence_action_id
      ,p_object_version_number         =>     p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'HR_NL_ABSENCE_ACTION_BK3'
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
  --  p_some_warning           := <local_var_set_in_process_logic>;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to DELETE_ABSENCE_ACTION;
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
    rollback to DELETE_ABSENCE_ACTION;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end DELETE_ABSENCE_ACTION;
--
end HR_NL_ABSENCE_ACTION_api;

/
