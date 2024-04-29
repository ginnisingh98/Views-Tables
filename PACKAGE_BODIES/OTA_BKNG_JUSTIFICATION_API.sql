--------------------------------------------------------
--  DDL for Package Body OTA_BKNG_JUSTIFICATION_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_BKNG_JUSTIFICATION_API" as
/* $Header: otbjsapi.pkb 120.0 2005/05/29 07:02:38 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  OTA_BKNG_JUSTIFICATION_API.';
--
-- ----------------------------------------------------------------------------
-- |-------------------------< CREATE_BOOKING_JUSTIFICATION >------------------|
-- ----------------------------------------------------------------------------
--
procedure create_booking_justification
(
  p_effective_date               in date,
  p_validate                     in boolean,
  p_business_group_id            in number,
  p_priority_level               in varchar2,
  p_justification_text           in varchar2,
  p_start_date_active            in date,
  p_end_date_active              in date,
  p_booking_justification_id     out nocopy number,
  p_object_version_number        out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_booking_justification_id ota_bkng_justifications_b.booking_justification_id%TYPE;
  l_object_version_number ota_bkng_justifications_b.object_version_number%TYPE;
  l_effective_date date;
  l_proc                    varchar2(72) := g_package||' create_booking_justification';
 begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint CREATE_BOOKING_JUSTIFICATION;
  l_effective_date := trunc(p_effective_date);


  begin
  ota_bkng_justification_bk1.create_booking_justification_b
  (  p_effective_date               => p_effective_date
    ,p_validate                     => p_validate
    ,p_priority_level     => p_priority_level
    ,p_start_date_active  => p_start_date_active
   ,p_end_date_active  => p_end_date_active
   ,p_business_group_id  => p_business_group_id
   ,p_justification_text  =>  p_justification_text
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_BKNG_JUSTIFICATION'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Process Logic
  --
  ota_bjs_ins.ins
  (
   p_effective_date                 =>   p_effective_date
  ,p_business_group_id              =>   p_business_group_id
  ,p_start_date_active              =>   p_start_date_active
  ,p_end_date_active                =>   p_end_date_active
  ,p_priority_level                        => p_priority_level
  ,p_booking_justification_id   => l_booking_justification_id
  ,p_object_version_number          =>   l_object_version_number
  );

  --
  -- Set all output arguments
  --
  p_booking_justification_id        := l_booking_justification_id;
  p_object_version_number   := l_object_version_number;


  ota_bjt_ins.ins_tl
    ( p_language_code                             => USERENV('LANG')
      ,p_booking_justification_id             => p_booking_justification_id
      ,p_justification_text                         => rtrim(p_justification_text)
  );

  begin


    ota_bkng_justification_bk1.create_booking_justification_a
  (  p_effective_date               => p_effective_date
    ,p_validate                     => p_validate
    ,p_priority_level     => p_priority_level
    ,p_start_date_active  => p_start_date_active
   ,p_end_date_active  => p_end_date_active
   ,p_business_group_id  => p_business_group_id
   ,p_justification_text  =>  p_justification_text
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_BKNG_JUSTIFICATION'
        ,p_hook_type   => 'AP'
        );
  end;


  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;

  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to CREATE_BOOKING_JUSTIFICATION;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_booking_justification_id := null;
    p_object_version_number   := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to CREATE_BOOKING_JUSTIFICATION;
    p_booking_justification_id     := null;
    p_object_version_number   := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_booking_justification;
-- ----------------------------------------------------------------------------
-- |-------------------------< UPDATE_BOOKING_JUSTIFICATION >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_booking_justification
  (
  p_effective_date               in date,
  p_booking_justification_id     in number,
  p_object_version_number        in out nocopy number,
  p_priority_level               in varchar2,
  p_justification_text           in varchar2,
  p_start_date_active            in date,
  p_end_date_active              in date,
  p_business_group_id            in number,
  p_validate                     in boolean
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' Update Booking Justification';
  l_object_version_number   number := p_object_version_number;
  l_effective_date date;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint UPDATE_BOOKING_JUSTIFICATION;
  l_effective_date := trunc(p_effective_date);

  begin
  ota_bkng_justification_bk2.update_booking_justification_b
  (p_effective_date               => p_effective_date
    ,p_booking_justification_id             => p_booking_justification_id
    ,p_object_version_number        => p_object_version_number
    ,p_priority_level     => p_priority_level
    ,p_start_date_active            => p_start_date_active
    ,p_end_date_active              => p_end_date_active
    ,p_business_group_id            => p_business_group_id
    ,p_justification_text            => p_justification_text
    ,p_validate                     => p_validate
    );


  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_BKNG_JUSTIFICATION'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  --
  -- Process Logic
  --
  ota_bjs_upd.upd
  (
   p_effective_date                 =>   p_effective_date
  ,p_business_group_id              =>   p_business_group_id
  ,p_start_date_active            => p_start_date_active
  ,p_end_date_active              => p_end_date_active
 ,p_priority_level                     => p_priority_level
  ,p_object_version_number          =>   p_object_version_number
  ,p_booking_justification_id        => p_booking_justification_id
  );

  ota_bjt_upd.upd_tl
 ( p_language_code                   => USERENV('LANG')
  ,p_booking_justification_id     => p_booking_justification_id
  ,p_justification_text                   => rtrim(p_justification_text)
  );


   begin
  ota_bkng_justification_bk2.update_booking_justification_a
  (p_effective_date               => p_effective_date
    ,p_booking_justification_id             => p_booking_justification_id
    ,p_object_version_number        => p_object_version_number
    ,p_priority_level     => p_priority_level
    ,p_start_date_active            => p_start_date_active
    ,p_end_date_active              => p_end_date_active
    ,p_business_group_id            => p_business_group_id
    ,p_justification_text            => p_justification_text
    ,p_validate                     => p_validate
    );


  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_BKNG_JUSTIFICATION'
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
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to UPDATE_BOOKING_JUSTIFICATION;
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
    rollback to UPDATE_BOOKING_JUSTIFICATION;
    p_object_version_number  := l_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_booking_justification;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< DELETE_BOOKING_JUSTIFICATION >-------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_booking_justification
  (
  p_booking_justification_id                in number,
  p_object_version_number              in number,
  p_validate                           in boolean
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' Delete Booking Justification';
  --
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint DELETE_BOOKING_JUSTIFICATION;
  --
  -- Truncate the time portion from all IN date parameters
  --
  --

  begin
  ota_bkng_justification_bk3.delete_booking_justification_b
  (p_booking_justification_id             => p_booking_justification_id
    ,p_object_version_number        => p_object_version_number
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_BKNG_JUSTIFICATION'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Process Logic
  --
  ota_bjt_del.del_tl
    (p_booking_justification_id   => p_booking_justification_id
    );

  ota_bjs_del.del
  (
  p_booking_justification_id         => p_booking_justification_id             ,
  p_object_version_number    => p_object_version_number
  );


  begin
  ota_bkng_justification_bk3.delete_booking_justification_a
  (p_booking_justification_id             => p_booking_justification_id
    ,p_object_version_number        => p_object_version_number
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_BKNG_JUSTIFICATION'
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
  hr_utility.set_location(' Leaving:'||l_proc, 170);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to DELETE_BOOKING_JUSTIFICATION;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 180);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to DELETE_BOOKING_JUSTIFICATION;
    hr_utility.set_location(' Leaving:'||l_proc, 190);
    raise;
end delete_booking_justification;
--
end ota_bkng_justification_api;

/
