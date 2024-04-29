--------------------------------------------------------
--  DDL for Package Body OTA_TCC_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_TCC_API" as
/* $Header: ottccapi.pkb 115.2 2002/11/29 13:15:39 jbharath noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'OTA_TCC_API.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< <create_cross_charge> >------------------|
-- ----------------------------------------------------------------------------
--
procedure create_cross_charge
  (p_effective_date                 in     date
  ,p_business_group_id              in     number
  ,p_gl_set_of_books_id             in     number
  ,p_type                           in     varchar2
  ,p_from_to                        in     varchar2
  ,p_start_date_active              in     date
  ,p_end_date_active                in     date     default null
  ,p_cross_charge_id                   out nocopy number
  ,p_object_version_number             out nocopy number
  ,p_validate                       in     boolean default false
  ) is
  --
  -- Declare cursors and local variables
  --
  l_effective_date	date;
  l_proc                varchar2(72) := g_package||'create_Cross_charge';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_cross_charges;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);

  --
  -- Call Before Process User Hook
  --
  begin
    OTA_TCC_BK1.create_cross_charge_b
  (p_effective_date		     => l_effective_date
  ,p_business_group_id        => p_business_group_id
  ,p_gl_set_of_books_id       => p_gl_set_of_books_id
  ,p_type                     => p_type
  ,p_from_to                  => p_from_to
  ,p_start_date_active        => p_start_date_active
  ,p_end_date_active          => p_end_date_active
  ,p_cross_charge_id          => p_cross_charge_id
  ,p_object_version_number    => p_object_version_number
  );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_cross_charge_b'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --



  --
  -- Process Logic
  --

ota_tcc_ins.ins
(p_effective_date		     => l_effective_date
  ,p_business_group_id        => p_business_group_id
  ,p_gl_set_of_books_id       => p_gl_set_of_books_id
  ,p_type                     => p_type
  ,p_from_to                  => p_from_to
  ,p_start_date_active        => p_start_date_active
  ,p_end_date_active          => p_end_date_active
  ,p_cross_charge_id          => p_cross_charge_id
  ,p_object_version_number    => p_object_version_number
  ,p_validate                 => p_validate
   );

  --
  -- Call After Process User Hook
  --
  begin
    OTA_TCC_BK1.create_cross_charge_a
   (p_effective_date		     => l_effective_date
  ,p_business_group_id        => p_business_group_id
  ,p_gl_set_of_books_id       => p_gl_set_of_books_id
  ,p_type                     => p_type
  ,p_from_to                  => p_from_to
  ,p_start_date_active        => p_start_date_active
  ,p_end_date_active          => p_end_date_active
  ,p_cross_charge_id          => p_cross_charge_id
  ,p_object_version_number    => p_object_version_number
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_cross_charge_a'
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
    rollback to create_cross_charges;
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
    rollback to create_cross_charges;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_cross_charge;
--



-- ----------------------------------------------------------------------------
-- |--------------------------< <update_cross_charge> >-------------------|
-- ----------------------------------------------------------------------------
--
procedure update_cross_charge
  (p_effective_date               in     date
  ,p_cross_charge_id              in     number
  ,p_object_version_number        in out nocopy number
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_gl_set_of_books_id           in     number    default hr_api.g_number
  ,p_type                         in     varchar2  default hr_api.g_varchar2
  ,p_from_to                      in     varchar2  default hr_api.g_varchar2
  ,p_start_date_active            in     date      default hr_api.g_date
  ,p_end_date_active              in     date      default hr_api.g_date
  ,p_validate                     in     boolean    default false
  ) is


  l_effective_date	date;
  l_proc                varchar2(72) := g_package||'update_cross_charge';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_cross_charges;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);

  --
  -- Call Before Process User Hook
  --
  begin
    OTA_TCC_BK2.update_cross_charge_b
  (p_effective_date		=> l_effective_date
  ,p_business_group_id        => p_business_group_id
  ,p_gl_set_of_books_id       => p_gl_set_of_books_id
  ,p_type                     => p_type
  ,p_from_to                  => p_from_to
  ,p_start_date_active        => p_start_date_active
  ,p_end_date_active          => p_end_date_active
  ,p_cross_charge_id          => p_cross_charge_id
  ,p_object_version_number    => p_object_version_number
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_cross_charge_b'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --

ota_tcc_upd.upd
(p_effective_date		     => l_effective_date
  ,p_business_group_id        => p_business_group_id
  ,p_gl_set_of_books_id       => p_gl_set_of_books_id
  ,p_type                     => p_type
  ,p_from_to                  => p_from_to
  ,p_start_date_active        => p_start_date_active
  ,p_end_date_active          => p_end_date_active
  ,p_cross_charge_id          => p_cross_charge_id
  ,p_object_version_number    => p_object_version_number
  ,p_validate                 => p_validate
   );


  --
  -- Process Logic
  --



  --
  -- Call After Process User Hook
  --
  begin
    OTA_TCC_BK2.update_cross_charge_a
  (p_effective_date		=> l_effective_date
  ,p_business_group_id        => p_business_group_id
  ,p_gl_set_of_books_id       => p_gl_set_of_books_id
  ,p_type                     => p_type
  ,p_from_to                  => p_from_to
  ,p_start_date_active        => p_start_date_active
  ,p_end_date_active          => p_end_date_active
  ,p_cross_charge_id          => p_cross_charge_id
  ,p_object_version_number    => p_object_version_number
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_cross_charge_a'
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
    rollback to update_cross_charges;
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
    rollback to update_cross_charges;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_cross_charge;
--

end OTA_TCC_API;

/
