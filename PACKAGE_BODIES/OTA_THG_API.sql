--------------------------------------------------------
--  DDL for Package Body OTA_THG_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_THG_API" as
/* $Header: otthgapi.pkb 115.2 2002/11/29 13:17:28 jbharath noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'OTA_THG_API.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< <create_non_ota_histories> >------------------|
-- ----------------------------------------------------------------------------
--
procedure create_hr_gl_flex
  (p_effective_date               in     date
  ,p_cross_charge_id              in     number
  ,p_segment                      in     varchar2
  ,p_segment_num                  in     number
  ,p_hr_data_source               in     varchar2 default null
  ,p_constant                     in     varchar2 default null
  ,p_hr_cost_segment              in     varchar2 default null
  ,p_gl_default_segment_id             out nocopy number
  ,p_object_version_number             out nocopy number
  ,p_validate                     in     boolean    default false
  ) is
  --
  -- Declare cursors and local variables
  --
  l_effective_date	date;
  l_proc                varchar2(72) := g_package||'create_hr_gl_flex';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_hr_gl_flex;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);

  --
  -- Call Before Process User Hook
  --
  begin
    OTA_THG_BK1.create_hr_gl_flex_b
  (p_effective_date		     => l_effective_date
  ,p_cross_charge_id         => p_cross_charge_id
  ,p_segment                 => p_segment
  ,p_segment_num             => p_segment_num
  ,p_hr_data_source          => p_hr_data_source
  ,p_constant                => p_constant
  ,p_hr_cost_segment         => p_hr_cost_segment
  ,p_gl_default_segment_id   => p_gl_default_segment_id
  ,p_object_version_number   => p_object_version_number
   );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_hr_gl_flex_b'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --



  --
  -- Process Logic
  --

ota_thg_ins.ins
(p_effective_date		     => l_effective_date
  ,p_cross_charge_id         => p_cross_charge_id
  ,p_segment                 => p_segment
  ,p_segment_num             => p_segment_num
  ,p_hr_data_source          => p_hr_data_source
  ,p_constant                => p_constant
  ,p_hr_cost_segment         => p_hr_cost_segment
  ,p_gl_default_segment_id   => p_gl_default_segment_id
  ,p_object_version_number   => p_object_version_number
  ,p_validate                => p_validate
   );

  --
  -- Call After Process User Hook
  --
  begin
    OTA_THG_BK1.create_hr_gl_flex_a
   (p_effective_date		     => l_effective_date
  ,p_cross_charge_id         => p_cross_charge_id
  ,p_segment                 => p_segment
  ,p_segment_num             => p_segment_num
  ,p_hr_data_source          => p_hr_data_source
  ,p_constant                => p_constant
  ,p_hr_cost_segment         => p_hr_cost_segment
  ,p_gl_default_segment_id   => p_gl_default_segment_id
  ,p_object_version_number   => p_object_version_number
   );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_hr_gl_flex_a'
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
  /*p_id                     := <local_var_set_in_process_logic>;
  p_object_version_number  := <local_var_set_in_process_logic>;
  p_some_warning           := <local_var_set_in_process_logic>; */
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_hr_gl_flex;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
  /*  p_id                     := null;
    p_object_version_number  := null;
    p_some_warning           := <local_var_set_in_process_logic>;*/
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_hr_gl_flex;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_hr_gl_flex;
--



-- ----------------------------------------------------------------------------
-- |--------------------------< <update_hr_gl_flex> >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_hr_gl_flex
  (p_effective_date               in     date
  ,p_gl_default_segment_id        in     number
  ,p_object_version_number        in out nocopy number
  ,p_cross_charge_id              in     number    default hr_api.g_number
  ,p_segment                      in     varchar2  default hr_api.g_varchar2
  ,p_segment_num                  in     number    default hr_api.g_number
  ,p_hr_data_source               in     varchar2  default hr_api.g_varchar2
  ,p_constant                     in     varchar2  default hr_api.g_varchar2
  ,p_hr_cost_segment              in     varchar2  default hr_api.g_varchar2
  ,p_validate                     in     boolean    default false
  ) is


  l_effective_date	date;
  l_proc                varchar2(72) := g_package||'update_hr_gl_flex';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_hr_gl_flex;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);

  --
  -- Call Before Process User Hook
  --
  begin
    OTA_THG_BK2.update_hr_gl_flex_b
  (p_effective_date	     => l_effective_date
  ,p_cross_charge_id         => p_cross_charge_id
  ,p_segment                 => p_segment
  ,p_segment_num             => p_segment_num
  ,p_hr_data_source          => p_hr_data_source
  ,p_constant                => p_constant
  ,p_hr_cost_segment         => p_hr_cost_segment
  ,p_gl_default_segment_id   => p_gl_default_segment_id
  ,p_object_version_number   => p_object_version_number
   );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_hr_gl_flex_b'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --

ota_thg_upd.upd
(p_effective_date		     => l_effective_date
  ,p_cross_charge_id         => p_cross_charge_id
  ,p_segment                 => p_segment
  ,p_segment_num             => p_segment_num
  ,p_hr_data_source          => p_hr_data_source
  ,p_constant                => p_constant
  ,p_hr_cost_segment         => p_hr_cost_segment
  ,p_gl_default_segment_id   => p_gl_default_segment_id
  ,p_object_version_number   => p_object_version_number
  ,p_validate                => p_validate
   );


  --
  -- Process Logic
  --



  --
  -- Call After Process User Hook
  --
  begin
    OTA_THG_BK2.update_hr_gl_flex_a
  (p_effective_date		     => l_effective_date
  ,p_cross_charge_id         => p_cross_charge_id
  ,p_segment                 => p_segment
  ,p_segment_num             => p_segment_num
  ,p_hr_data_source          => p_hr_data_source
  ,p_constant                => p_constant
  ,p_hr_cost_segment         => p_hr_cost_segment
  ,p_gl_default_segment_id   => p_gl_default_segment_id
  ,p_object_version_number   => p_object_version_number
   );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_hr_gl_flex_a'
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
 /* p_id                     := <local_var_set_in_process_logic>;
  p_object_version_number  := <local_var_set_in_process_logic>;
  p_some_warning           := <local_var_set_in_process_logic>;*/
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_hr_gl_flex;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
  /*  p_id                     := null;
    p_object_version_number  := null;
    p_some_warning           := <local_var_set_in_process_logic>; */
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_hr_gl_flex;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_hr_gl_flex;
--

end OTA_THG_API;

/
