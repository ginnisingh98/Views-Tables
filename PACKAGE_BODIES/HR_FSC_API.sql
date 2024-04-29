--------------------------------------------------------
--  DDL for Package Body HR_FSC_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_FSC_API" as
/* $Header: hrfscapi.pkb 115.2 2002/12/08 05:38:01 hjonnala noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_fsc_api.';
--
-- ----------------------------------------------------------------------------
-- |----------------------< create_form_tab_stacked_canvas >------------------|
-- ----------------------------------------------------------------------------
--
procedure create_form_tab_stacked_canvas
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_form_tab_page_id              in     number
  ,p_form_canvas_id                in     number
  ,p_form_tab_stacked_canvas_id       out nocopy number
  ,p_object_version_number            out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc                varchar2(72) := g_package||'create_form_tab_stacked_canvas';
  l_form_tab_stacked_canvas_id number;
  l_object_version_number number;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_form_tab_stacked_canvas;
  --
  -- Truncate the time portion from all IN date parameters
  --
     -- p_effective_date := TRUNC(p_effective_date);
  --
  -- Call Before Process User Hook
  --
  begin
    hr_fsc_api_bk1.create_fsc_b
      (p_effective_date                => TRUNC(p_effective_date)
      ,p_form_tab_page_id              => p_form_tab_page_id
      ,p_form_canvas_id                => p_form_canvas_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_form_tab_stacked_canvas'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
  hr_fsc_ins.ins(p_form_tab_page_id             => p_form_tab_page_id
                 ,p_form_canvas_id               => p_form_canvas_id
                 ,p_form_tab_stacked_canvas_id   => l_form_tab_stacked_canvas_id
                 ,p_object_version_number        => l_object_version_number);

  --
  -- Call After Process User Hook
  --
  begin
    hr_fsc_api_bk1.create_fsc_a
      (p_effective_date                => TRUNC(p_effective_date)
      ,p_form_tab_page_id              => p_form_tab_page_id
      ,p_form_canvas_id                => p_form_canvas_id
      ,p_form_tab_stacked_canvas_id    => l_form_tab_stacked_canvas_id
      ,p_object_version_number         => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_form_tab_stacked_canvas'
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
  p_form_tab_stacked_canvas_id    := l_form_tab_stacked_canvas_id;
  p_object_version_number         := l_object_version_number;
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_form_tab_stacked_canvas;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_form_tab_stacked_canvas_id    := null;
    p_object_version_number         := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_form_tab_stacked_canvas;
    -- Set out parameters.
    p_form_tab_stacked_canvas_id    := null;
    p_object_version_number         := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_form_tab_stacked_canvas;
--
-- ----------------------------------------------------------------------------
-- |---------------------< delete_form_tab_stacked_canvas >-------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_form_tab_stacked_canvas
  (p_validate                      in     boolean  default false
  ,p_form_tab_stacked_canvas_id    in     number
  ,p_object_version_number         in     number
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc                varchar2(72) := g_package||'delete_form_tab_stacked_canvas';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_form_tab_stacked_canvas;
  --
  -- Call Before Process User Hook
  --
  begin
    hr_fsc_api_bk2.delete_fsc_b
      (p_form_tab_stacked_canvas_id    => p_form_tab_stacked_canvas_id
      ,p_object_version_number         => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_form_tab_stacked_canvas'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Process Logic
  --
  hr_fsc_del.del(
            p_form_tab_stacked_canvas_id   => p_form_tab_stacked_canvas_id
            ,p_object_version_number        => p_object_version_number);

  --
  -- Call After Process User Hook
  --
  begin
    hr_fsc_api_bk2.delete_fsc_a
      (p_form_tab_stacked_canvas_id    => p_form_tab_stacked_canvas_id
      ,p_object_version_number         => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_form_tab_stacked_canvas'
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
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_form_tab_stacked_canvas;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to delete_form_tab_stacked_canvas;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_form_tab_stacked_canvas;
--
end hr_fsc_api;

/
