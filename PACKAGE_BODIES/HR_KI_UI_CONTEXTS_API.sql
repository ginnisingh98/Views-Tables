--------------------------------------------------------
--  DDL for Package Body HR_KI_UI_CONTEXTS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_KI_UI_CONTEXTS_API" as
/* $Header: hrucxapi.pkb 120.0 2005/05/31 03:37:19 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'HR_KI_UI_CONTEXTS_API';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< CREATE_UI_CONTEXT >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure CREATE_UI_CONTEXT
    (p_validate                      in     boolean  default false
    ,p_label                         in     varchar2
    ,p_location                      in     varchar2
    ,p_user_interface_id             in     number
    ,p_ui_context_id                 out    nocopy   number
    ,p_object_version_number         out    nocopy   number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'CREATE_UI_CONTEXT';
  l_ui_context_id      number;
  l_object_version_number number;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint CREATE_UI_CONTEXT;
  --
  -- Remember IN OUT parameter IN values
  --
  --l_in_out_parameter := p_in_out_parameter;

  --
  -- Call Before Process User Hook
  --
  begin
    hr_ki_ui_contexts_bk1.CREATE_UI_CONTEXT_b
      (
        p_user_interface_id =>p_user_interface_id
       ,p_label             => p_label
       ,p_location          => p_location
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_UI_CONTEXT'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Process Logic
  --
  hr_ucx_ins.ins
     ( p_user_interface_id       => p_user_interface_id
      ,p_label                   => p_label
      ,p_location                => p_location
      ,p_ui_context_id           => l_ui_context_id
      ,p_object_version_number   => l_object_version_number
      );

  --
  -- Call After Process User Hook
  --
  begin
    hr_ki_ui_contexts_bk1.CREATE_UI_CONTEXT_a
      (
       p_user_interface_id       =>    p_user_interface_id
      ,p_label                   =>    p_label
      ,p_location                =>    p_location
      ,p_ui_context_id           =>    l_ui_context_id
      ,p_object_version_number   =>    l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_UI_CONTEXT'
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
  p_ui_context_id          := l_ui_context_id;
  p_object_version_number  := l_object_version_number;

  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to CREATE_UI_CONTEXT;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --

    p_ui_context_id         := null;
    p_object_version_number  := null;

    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to CREATE_UI_CONTEXT;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --

    p_ui_context_id         := null;
    p_object_version_number  := null;

    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end CREATE_UI_CONTEXT;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< DELETE_UI_CONTEXT >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure DELETE_UI_CONTEXT
  (
   p_validate                 in boolean         default false
  ,p_ui_context_id            in number
  ,p_object_version_number    in number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'DELETE_UI_CONTEXT';

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint DELETE_UI_CONTEXT;
  --
  -- Remember IN OUT parameter IN values
  --

  -- Call Before Process User Hook
  --
  begin
    hr_ki_ui_contexts_bk2.DELETE_UI_CONTEXT_b
      (
        p_ui_context_id           => p_ui_context_id
       ,p_object_version_number   => p_object_version_number

      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_UI_CONTEXT'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Process Logic
  --
  hr_ucx_shd.lck
     (
      p_ui_context_id           => p_ui_context_id
     ,p_object_version_number   => p_object_version_number
     );
  hr_ucx_del.del
     (
      p_ui_context_id          => p_ui_context_id
     ,p_object_version_number   => p_object_version_number
      );


  --
  -- Call After Process User Hook
  --
  begin
    hr_ki_ui_contexts_bk2.DELETE_UI_CONTEXT_a
      (
       p_ui_context_id           =>    p_ui_context_id
      ,p_object_version_number   =>    p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_UI_CONTEXT'
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
    rollback to DELETE_UI_CONTEXT;
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
    rollback to DELETE_UI_CONTEXT;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end DELETE_UI_CONTEXT;
end HR_KI_UI_CONTEXTS_API;

/
