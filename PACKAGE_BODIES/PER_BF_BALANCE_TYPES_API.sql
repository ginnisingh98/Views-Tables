--------------------------------------------------------
--  DDL for Package Body PER_BF_BALANCE_TYPES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_BF_BALANCE_TYPES_API" as
/* $Header: pebbtapi.pkb 115.6 2002/11/29 15:28:12 apholt noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  per_bf_balance_types_api.';
--
-- ----------------------------------------------------------------------------
-- |-----------------------< <create_balance_type> >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_balance_type
 ( p_balance_type_id	          out nocopy    number
  ,p_object_version_number        out nocopy    number
  --
  ,p_input_value_id               in     number         default null
  ,p_business_group_id            in     number
  ,p_displayed_name               in     varchar2
  ,p_internal_name                in     varchar2
  ,p_uom                          in     varchar2       default null
  ,p_currency                     in     varchar2       default null
  ,p_category                     in     varchar2       default null
  ,p_date_from                    in     date           default null
  ,p_date_to                      in     date           default null
  ,p_validate                     in     boolean        default false
  ,p_effective_date               in     date
  )
is
  --
  --
  -- Declare cursors and local variables
  --
  l_balance_type_id        per_bf_balance_types.balance_type_id%TYPE;
  l_object_version_number  per_bf_balance_types.object_version_number%TYPE;
  --
  l_proc                varchar2(72) := g_package||'create_balance_type';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_balance_type;
  hr_utility.set_location(l_proc, 20);
  --
  -- Truncate the time portion from all IN date parameters
  --

  --
  -- Call Before Process User Hook
  --
  begin
    per_bf_balance_types_bk1.create_balance_type_b
      (
        p_input_value_id               => p_input_value_id
       ,p_business_group_id            => p_business_group_id
       ,p_displayed_name               => p_displayed_name
       ,p_internal_name                => p_internal_name
       ,p_uom                          => p_uom
       ,p_currency                     => p_currency
       ,p_category                     => p_category
       ,p_date_from                    => p_date_from
       ,p_date_to                      => p_date_to
       ,p_effective_date               => p_effective_date
       );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_BALANCE_TYPE'
        ,p_hook_type   => 'BP'
        );
  end;
  hr_utility.set_location(l_proc, 30);
  --
  -- Validation in addition to Row Handlers
  --
  hr_utility.set_location(l_proc, 40);
  --
  -- Process Logic
  --
  per_bbt_ins.ins
  (p_effective_date               => p_effective_date
  ,p_input_value_id               => p_input_value_id
  ,p_business_group_id            => p_business_group_id
  ,p_displayed_name               => p_displayed_name
  ,p_internal_name                => p_internal_name
  ,p_uom                          => p_uom
  ,p_currency                     => p_currency
  ,p_category                     => p_category
  ,p_date_from                    => p_date_from
  ,p_date_to                      => p_date_to
  --
  ,p_balance_type_id              => l_balance_type_id
  ,p_object_version_number        => l_object_version_number
  );

  hr_utility.set_location(l_proc, 50);
  --
  -- Call After Process User Hook
  --
  begin
    per_bf_balance_types_bk1.create_balance_type_a
      (
        p_input_value_id               => p_input_value_id
       ,p_business_group_id            => p_business_group_id
       ,p_displayed_name               => p_displayed_name
       ,p_internal_name                => p_internal_name
       ,p_uom                          => p_uom
       ,p_currency                     => p_currency
       ,p_category                     => p_category
       ,p_date_from                    => p_date_from
       ,p_date_to                      => p_date_to
       ,p_effective_date               => p_effective_date
       ,p_balance_type_id              => l_balance_type_id
       ,p_object_version_number        => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_BALANCE_TYPE'
        ,p_hook_type   => 'AP'
        );
  end;
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_balance_type_id        := l_balance_type_id;
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_balance_type;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_balance_type_id        := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    --set out variables
    p_balance_type_id    := null;
    p_object_version_number  := null;
    rollback to create_balance_type;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_balance_type;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< <update_balance_type> >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_balance_type
 ( p_balance_type_id              in number
  ,p_input_value_id               in number     default hr_api.g_number
  ,p_displayed_name               in varchar2   default hr_api.g_varchar2
  ,p_internal_name                in varchar2   default hr_api.g_varchar2
  ,p_uom                          in varchar2   default hr_api.g_varchar2
  ,p_currency                     in varchar2   default hr_api.g_varchar2
  ,p_category                     in varchar2   default hr_api.g_varchar2
  ,p_date_from                    in date       default hr_api.g_date
  ,p_date_to                      in date       default hr_api.g_date
  ,p_validate                     in boolean    default false
  ,p_effective_date               in date
  ,p_object_version_number        in out nocopy number
  )
is
  --
  --
  -- Declare cursors and local variables
  --
  l_object_version_number  per_bf_balance_types.object_version_number%TYPE;
  --
  l_proc                varchar2(72) := g_package||'update_balance_type';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_balance_type;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Truncate the time portion from all IN date parameters
  --
  --
  -- Call Before Process User Hook
  --
  begin
    per_bf_balance_types_bk2.update_balance_type_b
      (
	p_balance_type_id              => p_balance_type_id
       ,p_input_value_id               => p_input_value_id
       ,p_displayed_name               => p_displayed_name
       ,p_internal_name                => p_internal_name
       ,p_uom                          => p_uom
       ,p_currency                     => p_currency
       ,p_category                     => p_category
       ,p_date_from                    => p_date_from
       ,p_date_to                      => p_date_to
       ,p_effective_date               => p_effective_date
       ,p_object_version_number        => p_object_version_number
       );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_BALANCE_TYPE'
        ,p_hook_type   => 'BP'
        );
  end;
  hr_utility.set_location(l_proc, 30);
  --
  -- Validation in addition to Row Handlers
  --
  hr_utility.set_location(l_proc, 40);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  per_bbt_upd.upd
  (p_effective_date               => p_effective_date
  ,p_input_value_id               => p_input_value_id
  ,p_displayed_name               => p_displayed_name
  ,p_internal_name                => p_internal_name
  ,p_uom                          => p_uom
  ,p_currency                     => p_currency
  ,p_category                     => p_category
  ,p_date_from                    => p_date_from
  ,p_date_to                      => p_date_to
  --
  ,p_balance_type_id              => p_balance_type_id
  ,p_object_version_number        => l_object_version_number
  );

  hr_utility.set_location(l_proc, 50);
  --
  -- Call After Process User Hook
  --
  begin
    per_bf_balance_types_bk2.update_balance_type_a
      (
        p_input_value_id               => p_input_value_id
       ,p_displayed_name               => p_displayed_name
       ,p_internal_name                => p_internal_name
       ,p_uom                          => p_uom
       ,p_currency                     => p_currency
       ,p_category                     => p_category
       ,p_date_from                    => p_date_from
       ,p_date_to                      => p_date_to
       ,p_effective_date               => p_effective_date
       ,p_balance_type_id              => p_balance_type_id
       ,p_object_version_number        => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_BALANCE_TYPE'
        ,p_hook_type   => 'AP'
        );
  end;
  hr_utility.set_location(l_proc, 60);
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
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_balance_type;
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
    --set out variables
    p_object_version_number  := null;
    rollback to update_balance_type;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_balance_type;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< <delete_balance_type> >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_balance_type
  (p_validate                           in boolean default false,
   p_balance_type_id                    in number,
   p_object_version_number              in number
  )
is
  --
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'delete_balance_type';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_balance_type;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Truncate the time portion from all IN date parameters
  --
  --
  -- Call Before Process User Hook
  --
  begin
    per_bf_balance_types_bk3.delete_balance_type_b
      (
        p_balance_type_id              => p_balance_type_id
      , p_object_version_number        => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_BALANCE_TYPE'
        ,p_hook_type   => 'BP'
        );
  end;
  hr_utility.set_location(l_proc, 30);
  --
  -- Validation in addition to Row Handlers
  --
  hr_utility.set_location(l_proc, 40);
  --
  -- Process Logic
  --
  per_bbt_del.del
  (
   p_balance_type_id              => p_balance_type_id
  ,p_object_version_number        => p_object_version_number
  );

  hr_utility.set_location(l_proc, 50);
  --
  -- Call After Process User Hook
  --
  begin
    per_bf_balance_types_bk3.delete_balance_type_a
      (
        p_balance_type_id              => p_balance_type_id
       ,p_object_version_number        => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_BALANCE_TYPE'
        ,p_hook_type   => 'AP'
        );
  end;
  hr_utility.set_location(l_proc, 60);
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
    rollback to delete_balance_type ;
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
    rollback to delete_balance_type;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_balance_type;
end PER_Bf_balance_types_api;

/
