--------------------------------------------------------
--  DDL for Package Body HR_KI_USER_INTERFACES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_KI_USER_INTERFACES_API" as
/* $Header: hritfapi.pkb 115.0 2004/01/09 04:56:44 vkarandi noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'HR_KI_USER_INTERFACES_API';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_user_interface >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_user_interface
  (
   p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_type                          in     varchar2
  ,p_form_name                     in     varchar2 default null
  ,p_page_region_code              in     varchar2 default null
  ,p_region_code                   in     varchar2 default null
  ,p_user_interface_id             out    nocopy   number
  ,p_object_version_number         out    nocopy   number
  )  is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'create_user_interface';
  l_user_interface_id     number;
  l_effective_date        date;
  l_object_version_number number;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_user_interface;
  --
  -- Remember IN OUT parameter IN values
  --
  --l_in_out_parameter := p_in_out_parameter;

  l_effective_date := trunc(p_effective_date);

  -- Call Before Process User Hook
  --
  begin
    hr_ki_user_interfaces_bk1.create_user_interface_b
      (
       p_effective_date                => l_effective_date
      ,p_type                          => p_type
      ,p_form_name                     => p_form_name
      ,p_page_region_code              => p_page_region_code
      ,p_region_code                   => p_region_code
      );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_user_interface'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Process Logic
  --
  hr_itf_ins.ins
     (
       p_effective_date                => l_effective_date
      ,p_type                          => p_type
      ,p_form_name                     => p_form_name
      ,p_page_region_code              => p_page_region_code
      ,p_region_code                   => p_region_code
      ,p_user_interface_id             => l_user_interface_id
      ,p_object_version_number         => l_object_version_number
     );

  --
  -- Call After Process User Hook
  --
  begin
    hr_ki_user_interfaces_bk1.create_user_interface_a
      (
       p_effective_date                => l_effective_date
      ,p_type                          => p_type
      ,p_form_name                     => p_form_name
      ,p_page_region_code              => p_page_region_code
      ,p_region_code                   => p_region_code
      ,p_user_interface_id             => l_user_interface_id
      ,p_object_version_number         => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_user_interface'
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
  p_user_interface_id      := l_user_interface_id;
  p_object_version_number  := l_object_version_number;

  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_user_interface;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --

    p_user_interface_id      := null;
    p_object_version_number  := null;

    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_user_interface;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --

    p_user_interface_id      := null;
    p_object_version_number  := null;

    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_user_interface;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_user_interface >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_user_interface
  (
   p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_user_interface_id             in     number
  ,p_type                          in     varchar2 default hr_api.g_varchar2
  ,p_form_name                     in     varchar2 default hr_api.g_varchar2
  ,p_page_region_code              in     varchar2 default hr_api.g_varchar2
  ,p_region_code                   in     varchar2 default hr_api.g_varchar2
  ,p_object_version_number         in out nocopy   number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'update_user_interface';
  l_object_version_number number := p_object_version_number;
  l_effective_date        date;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_user_interface;
  --
  -- Remember IN OUT parameter IN values
  --
  --l_in_out_parameter := p_in_out_parameter;

  l_effective_date := trunc(p_effective_date);

  --
  -- Call Before Process User Hook
  --
  begin
    hr_ki_user_interfaces_bk2.update_user_interface_b
      (
       p_effective_date                => l_effective_date
      ,p_type                          => p_type
      ,p_form_name                     => p_form_name
      ,p_page_region_code              => p_page_region_code
      ,p_region_code                   => p_region_code
      ,p_user_interface_id             => p_user_interface_id
      ,p_object_version_number         => p_object_version_number

      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_user_interface'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Process Logic
  --
  hr_itf_upd.upd
     (
       p_effective_date                => l_effective_date
      ,p_type                          => p_type
      ,p_form_name                     => p_form_name
      ,p_page_region_code              => p_page_region_code
      ,p_region_code                   => p_region_code
      ,p_user_interface_id             => p_user_interface_id
      ,p_object_version_number         => p_object_version_number

    );

  --
  -- Call After Process User Hook
  --
  begin
    hr_ki_user_interfaces_bk2.update_user_interface_a
      (
       p_effective_date                => l_effective_date
      ,p_type                          => p_type
      ,p_form_name                     => p_form_name
      ,p_page_region_code              => p_page_region_code
      ,p_region_code                   => p_region_code
      ,p_user_interface_id             => p_user_interface_id
      ,p_object_version_number         => p_object_version_number

      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_user_interface'
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

  -- p_object_version_number  := p_object_version_number;

  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_user_interface;
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
    rollback to update_user_interface;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --

    p_object_version_number  := l_object_version_number;

    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_user_interface;
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_user_interface >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_user_interface
  (
   p_validate                 in boolean	 default false
  ,p_user_interface_id        in number
  ,p_object_version_number    in number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'delete_user_interface';

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_user_interface;
  --
  -- Remember IN OUT parameter IN values
  --

  -- Call Before Process User Hook
  --
  begin
    hr_ki_user_interfaces_bk3.delete_user_interface_b
      (
        p_user_interface_id      => p_user_interface_id
       ,p_object_version_number  => p_object_version_number

      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_user_interface'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Process Logic
  --

  hr_itf_del.del
     (
      p_user_interface_id       => p_user_interface_id
     ,p_object_version_number   => p_object_version_number
      );


  --
  -- Call After Process User Hook
  --
  begin
    hr_ki_user_interfaces_bk3.delete_user_interface_a
      (
       p_user_interface_id       =>    p_user_interface_id
      ,p_object_version_number   =>    p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_user_interface'
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
    rollback to delete_user_interface;
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
    rollback to delete_user_interface;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_user_interface;
end HR_KI_USER_INTERFACES_API;

/
