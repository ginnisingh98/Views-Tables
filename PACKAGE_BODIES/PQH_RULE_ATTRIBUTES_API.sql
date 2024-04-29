--------------------------------------------------------
--  DDL for Package Body PQH_RULE_ATTRIBUTES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_RULE_ATTRIBUTES_API" as
/* $Header: pqrlaapi.pkb 115.0 2003/01/26 01:52:15 rpasapul noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'PQH_RULE_ATTRIBUTES_API.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< Insert_Rule_Attribute >------------------------|
-- ----------------------------------------------------------------------------
--
procedure Insert_Rule_Attribute
  (p_rule_set_id                    in     number
  ,p_attribute_code                 in     varchar2 default null
  ,p_operation_code                 in     varchar2 default null
  ,p_attribute_value                in     varchar2 default null
  ,p_rule_attribute_id                 out nocopy number
  ,p_object_version_number             out nocopy number) is
  --
  -- Declare cursors and local variables
  --

  l_proc  varchar2(72)       := g_package||'Insert_Rule_Attribute';
  l_object_Version_Number    PQH_RULE_ATTRIBUTES.OBJECT_VERSION_NUMBER%TYPE;
  L_Effective_Date           Date;
  l_rule_attribute_id		PQH_RULE_ATTRIBUTES.RULE_ATTRIBUTE_ID%TYPE;


begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint Insert_Rule_Attribute;

  --
  -- Call Before Process User Hook
  --
  begin
   PQH_RULE_ATTRIBUTES_BK1.Insert_Rule_Attribute_b
   (p_rule_set_id                   => p_rule_set_id
  ,p_attribute_code                 => p_attribute_code
  ,p_operation_code                 => p_operation_code
  ,p_attribute_value                => p_attribute_value
  ,p_rule_attribute_id              => p_rule_attribute_id
  ,p_object_version_number          => p_object_version_number
   );


  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQH_RULE_ATTRIBUTES_API.Insert_Rule_Attribute'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
     pqh_rla_ins.ins
     (p_rule_set_id                   => p_rule_set_id
  ,p_attribute_code                 => p_attribute_code
  ,p_operation_code                 => p_operation_code
  ,p_attribute_value                => p_attribute_value
  ,p_rule_attribute_id              => l_rule_attribute_id
  ,p_object_version_number          => l_object_version_number
     );

  --
  -- Call After Process User Hook
  --
  begin
     PQH_RULE_ATTRIBUTES_BK1.Insert_Rule_Attribute_a
     (p_rule_set_id                   => p_rule_set_id
  ,p_attribute_code                 => p_attribute_code
  ,p_operation_code                 => p_operation_code
  ,p_attribute_value                => p_attribute_value
  ,p_rule_attribute_id              => p_rule_attribute_id
  ,p_object_version_number          => p_object_version_number);

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQH_RULE_ATTRIBUTES_API.Insert_Rule_Attribute'
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
     p_rule_attribute_id := l_rule_attribute_id;
     p_object_version_number := l_object_version_number;


  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to Insert_Rule_Attribute;
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
    rollback to Insert_Rule_Attribute;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end Insert_Rule_Attribute;

--
-- ----------------------------------------------------------------------------
-- |--------------------------< Update_Rule_Attribute >--------------------------|
-- ----------------------------------------------------------------------------

procedure Update_Rule_Attribute
  (p_rule_attribute_id            in     number
  ,p_object_version_number        in out nocopy number
  ,p_rule_set_id                  in     number    default hr_api.g_number
  ,p_attribute_code               in     varchar2  default hr_api.g_varchar2
  ,p_operation_code               in     varchar2  default hr_api.g_varchar2
  ,p_attribute_value              in     varchar2  default hr_api.g_varchar2
) Is

  l_proc  varchar2(72)    := g_package||'Update_Rule_Attribute';
  l_object_Version_Number PQH_RULE_ATTRIBUTES.OBJECT_VERSION_NUMBER%TYPE := P_Object_version_Number;

Begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint Update_Rule_Attribute;
  --
  -- Call Before Process User Hook
  --
  begin

   PQH_RULE_ATTRIBUTES_BK2.Update_Rule_Attribute_b
  (p_rule_attribute_id            => p_rule_attribute_id
  ,p_object_version_number        => p_object_version_number
  ,p_rule_set_id                  => p_rule_set_id
  ,p_attribute_code               => p_attribute_code
  ,p_operation_code               => p_operation_code
  ,p_attribute_value              => p_attribute_value
  );

 exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'Update_Rule_Attribute'
        ,p_hook_type   => 'BP'
        );
  end;

  pqh_rla_upd.upd
  (p_rule_attribute_id            => p_rule_attribute_id
  ,p_object_version_number        => l_object_version_number
  ,p_rule_set_id                  => p_rule_set_id
  ,p_attribute_code               => p_attribute_code
  ,p_operation_code               => p_operation_code
  ,p_attribute_value              => p_attribute_value
);

--
--
  -- Call After Process User Hook
  --
  begin

   PQH_RULE_ATTRIBUTES_BK2.Update_Rule_Attribute_a
  (p_rule_attribute_id            => p_rule_attribute_id
  ,p_object_version_number        => p_object_version_number
  ,p_rule_set_id                  => p_rule_set_id
  ,p_attribute_code               => p_attribute_code
  ,p_operation_code               => p_operation_code
  ,p_attribute_value              => p_attribute_value
);

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'Update_Rule_Attribute'
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
    rollback to Update_Rule_Attribute;
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
    rollback to Update_Rule_Attribute;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end Update_Rule_Attribute;

--
-- ----------------------------------------------------------------------------
-- |-------------------< delete_Rule_Attribute>------------------------------|
-- ----------------------------------------------------------------------------
procedure delete_Rule_Attribute
  (p_rule_attribute_id                    in     number
  ,p_object_version_number                in     number
  ) Is   --

  -- Declare cursors and local variables
  --
  l_proc           varchar2(72) := g_package||'delete_Rule_Attribute';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_Rule_Attribute;
  --
  -- Call Before Process User Hook
  --
  begin
  PQH_RULE_ATTRIBUTES_BK3.Delete_Rule_Attribute_b
  (p_rule_attribute_id                    => p_rule_attribute_id
  ,p_object_version_number                => p_object_version_number
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_Rule_Attribute'
        ,p_hook_type   => 'BP');
  end;
  --
  -- Process Logic
  --
  pqh_rla_del.del
    (
p_rule_attribute_id                    => p_rule_attribute_id
  ,p_object_version_number                => p_object_version_number
    );
  --
  -- Call After Process User Hook
  --
  begin

   PQH_RULE_ATTRIBUTES_BK3.Delete_Rule_Attribute_a
  (
p_rule_attribute_id                    => p_rule_attribute_id
  ,p_object_version_number                => p_object_version_number
  );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_Rule_Attribute'
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
    rollback to delete_Rule_Attribute;
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
    rollback to delete_Rule_Attribute;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_Rule_Attribute;

end PQH_RULE_ATTRIBUTES_API;

/
