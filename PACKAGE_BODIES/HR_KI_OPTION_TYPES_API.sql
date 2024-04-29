--------------------------------------------------------
--  DDL for Package Body HR_KI_OPTION_TYPES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_KI_OPTION_TYPES_API" as
/* $Header: hrotyapi.pkb 115.0 2004/01/09 02:19:43 vkarandi noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'HR_KI_OPTION_TYPES_API';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< CREATE_OPTION_TYPE >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_option_type
    (p_validate                      in     boolean  default false
    ,p_language_code                 in     varchar2 default hr_api.userenv_lang
    ,p_option_type_key               in     varchar2
    ,p_display_type                  in     varchar2
    ,p_option_name                   in     varchar2
    ,p_option_type_id                out    nocopy   number
    ,p_object_version_number         out    nocopy   number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'create_option_type';
  l_option_type_id      number;
  l_language_code       varchar2(30);
  l_object_version_number number;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_option_type;
  --
  -- Remember IN OUT parameter IN values
  --
  --l_in_out_parameter := p_in_out_parameter;
  l_language_code:=p_language_code;

  hr_api.validate_language_code(p_language_code => l_language_code);

  --
  -- Call Before Process User Hook
  --
  begin
    hr_ki_option_types_bk1.create_option_type_b
      ( p_language_code   => l_language_code
       ,p_option_type_key => p_option_type_key
       ,p_display_type    => p_display_type
       ,p_option_name     => p_option_name
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_option_type'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Process Logic
  --
  hr_oty_ins.ins
     (p_option_type_key         => p_option_type_key
      ,p_display_type            => p_display_type
      ,p_option_type_id          => l_option_type_id
      ,p_object_version_number   => l_object_version_number
      );

  hr_ott_ins.ins_tl(
      p_language_code           => l_language_code
      ,p_option_type_id          => l_option_type_id
      ,p_option_name             => p_option_name
      );


  --
  -- Call After Process User Hook
  --
  begin
    hr_ki_option_types_bk1.create_option_type_a
      (
       p_language_code           =>    l_language_code
      ,p_option_type_key         =>    p_option_type_key
      ,p_display_type            =>    p_display_type
      ,p_option_name             =>    p_option_name
      ,p_option_type_id          =>    l_option_type_id
      ,p_object_version_number   =>    l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_option_type'
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
  p_option_type_id         := l_option_type_id;
  p_object_version_number  := l_object_version_number;

  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_option_type;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --

    p_option_type_id         := null;
    p_object_version_number  := null;

    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_option_type;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --

    p_option_type_id         := null;
    p_object_version_number  := null;

    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_option_type;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< UPDATE_OPTION_TYPE >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_option_type
  (p_validate                      in     boolean  default false
  ,p_language_code                 in     varchar2 default hr_api.userenv_lang
  ,p_display_type                  in     varchar2 default hr_api.g_varchar2
  ,p_option_name                   in     varchar2 default hr_api.g_varchar2
  ,p_option_type_id                in     number
  ,p_object_version_number         in out nocopy   number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'update_option_type';
  l_language_code       varchar2(30);
  l_object_version_number number := p_object_version_number;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_option_type;
  --
  -- Remember IN OUT parameter IN values
  --
  --l_in_out_parameter := p_in_out_parameter;
  l_language_code:=p_language_code;

  hr_api.validate_language_code(p_language_code => l_language_code);

  --
  -- Call Before Process User Hook
  --
  begin
    hr_ki_option_types_bk2.update_option_type_b
      ( p_language_code          => l_language_code
       ,p_display_type           => p_display_type
       ,p_option_name            => p_option_name
       ,p_option_type_id         => p_option_type_id
       ,p_object_version_number  => p_object_version_number

      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_option_type'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Process Logic
  --
  hr_oty_upd.upd
     (
      p_option_type_id          => p_option_type_id
     ,p_display_type            => p_display_type
     ,p_object_version_number   => p_object_version_number
      );

  hr_ott_upd.upd_tl(
      p_language_code            => l_language_code
      ,p_option_type_id          => p_option_type_id
      ,p_option_name             => p_option_name
      );


  --
  -- Call After Process User Hook
  --
  begin
    hr_ki_option_types_bk2.update_option_type_a
      (
       p_language_code           =>    l_language_code
      ,p_display_type            =>    p_display_type
      ,p_option_name             =>    p_option_name
      ,p_option_type_id          =>    p_option_type_id
      ,p_object_version_number   =>    p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_option_type'
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
    rollback to update_option_type;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --

    p_object_version_number  := l_object_version_number;

    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_option_type;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --

    p_object_version_number  := l_object_version_number;

    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_option_type;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< DELETE_OPTION_TYPE >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_option_type
  (
   p_validate                 in boolean         default false
  ,p_option_type_id           in number
  ,p_object_version_number    in number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'delete_option_type';

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_option_type;
  --
  -- Remember IN OUT parameter IN values
  --

  -- Call Before Process User Hook
  --
  begin
    hr_ki_option_types_bk3.delete_option_type_b
      (
       p_option_type_id          => p_option_type_id
       ,p_object_version_number  => p_object_version_number

      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_option_type'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Process Logic
  --
  hr_oty_shd.lck
     (
      p_option_type_id          => p_option_type_id
     ,p_object_version_number   => p_object_version_number
     );
  hr_ott_del.del_tl(
      p_option_type_id          => p_option_type_id
      );
  hr_oty_del.del
     (
      p_option_type_id          => p_option_type_id
     ,p_object_version_number   => p_object_version_number
      );


  --
  -- Call After Process User Hook
  --
  begin
    hr_ki_option_types_bk3.delete_option_type_a
      (
       p_option_type_id          =>    p_option_type_id
      ,p_object_version_number   =>    p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_option_type'
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
    rollback to delete_option_type;
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
    rollback to delete_option_type;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_option_type;
end HR_KI_OPTION_TYPES_API;

/
