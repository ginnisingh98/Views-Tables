--------------------------------------------------------
--  DDL for Package Body PQH_DE_LEVEL_CODES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_DE_LEVEL_CODES_API" as
/* $Header: pqlcdapi.pkb 115.1 2002/12/03 00:07:42 rpasapul noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'PQH_DE_LEVEL_CODES_API.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< Insert_LEVEL_CODES >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure Insert_LEVEL_CODES
   (p_validate                      in  boolean  default false
  ,p_effective_date                in  date
  ,p_level_number_id               in  number
  ,p_level_code                    in  varchar2
  ,p_description                   in  varchar2
  ,p_gradual_value_number          in  number
  ,p_level_code_id                 out nocopy number
  ,p_object_version_number         out nocopy number
  )
 is
  --
  -- Declare cursors and local variables
  --

  l_proc  varchar2(72)    := g_package||'Insert_LEVEL_CODES';
  l_object_Version_Number PQH_DE_LEVEL_CODES.OBJECT_VERSION_NUMBER%TYPE;
  L_Effective_Date        Date;
  l_level_code_id         PQH_DE_LEVEL_CODES.LEVEL_CODE_ID%TYPE;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint Insert_LEVEL_CODES;
  --
  -- Truncate the time portion from all IN date parameters
  --
     l_effective_date := Trunc(p_effective_Date);
  --
  -- Call Before Process User Hook
  --
  begin
   PQH_DE_LEVEL_CODES_BK1.Insert_LEVEL_CODES_b
  (p_effective_date             => L_Effective_Date
   ,p_level_number_id           => p_level_number_id
  ,p_level_code                 => p_level_code
  ,p_description                => p_description
  ,p_gradual_value_number       => p_gradual_value_number
  );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_LEVEL_CODES'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
     pqh_lcd_ins.ins
  (p_level_number_id            => p_level_number_id
  ,p_level_code                 => p_level_code
  ,p_description                => p_description
  ,p_gradual_value_number       => p_gradual_value_number
  ,p_level_code_id              => l_level_code_id
  ,p_object_version_number      => l_object_version_number
  );

  --
  -- Call After Process User Hook
  --
  begin


        PQH_DE_LEVEL_CODES_BK1.Insert_LEVEL_CODES_a
        (p_effective_date       => L_Effective_Date
   ,p_level_number_id           => p_level_number_id
  ,p_level_code                 => p_level_code
  ,p_description                => p_description
  ,p_gradual_value_number       => p_gradual_value_number
  ,p_level_code_id              => p_level_code_id
  ,p_object_version_number      => p_object_version_number
  );


  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'INSERT_LEVEL_CODES'
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
  P_LEVEL_CODE_ID            := l_LEVEL_CODE_ID;
  p_object_version_number   := l_object_version_number;

  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to Insert_LEVEL_CODES;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_LEVEL_CODE_ID          := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);

  when others then
    p_LEVEL_CODE_ID          := null;
    p_object_version_number  := null;
    --
    -- A validation or unexpected error has occured
    --
    rollback to Insert_LEVEL_CODES;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end Insert_LEVEL_CODES;

--
-- ----------------------------------------------------------------------------
-- |--------------------------< Update_LEVEL_CODES >--------------------------|
-- ----------------------------------------------------------------------------

procedure Update_LEVEL_CODES
 (p_validate                      in     boolean  default false
  ,p_effective_date               in     date
  ,p_level_code_id                in     number
  ,p_object_version_number        in out nocopy number
  ,p_level_number_id              in     number    default hr_api.g_number
  ,p_level_code                   in     varchar2  default hr_api.g_varchar2
  ,p_description                  in     varchar2  default hr_api.g_varchar2
  ,p_gradual_value_number         in     number    default hr_api.g_number
  )  Is

  l_proc  varchar2(72)      := g_package||'Update_LEVEL_CODES';
  l_object_Version_Number   PQH_DE_LEVEL_CODES.OBJECT_VERSION_NUMBER%TYPE := P_Object_version_Number;
  L_Effective_Date          Date;

Begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint Update_OPERATIONS;
  --
  -- Truncate the time portion from all IN date parameters
  --
     l_effective_date := Trunc(p_effective_Date);
  --
  -- Call Before Process User Hook
  --
  begin


PQH_DE_LEVEL_CODES_BK2.Update_LEVEL_CODES_b
 (p_effective_date                => L_Effective_Date
   ,p_level_number_id           => p_level_number_id
  ,p_level_code                 => p_level_code
  ,p_description                => p_description
  ,p_gradual_value_number       => p_gradual_value_number
  ,p_level_code_id              => p_level_code_id
  ,p_object_version_number      => p_object_version_number
  );


 exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_LEVEL_CODES'
        ,p_hook_type   => 'BP'
        );
  end;


pqh_lcd_upd.upd
 (p_level_number_id             => p_level_number_id
  ,p_level_code                 => p_level_code
  ,p_description                => p_description
  ,p_gradual_value_number       => p_gradual_value_number
  ,p_level_code_id              => p_level_code_id
  ,p_object_version_number      => l_object_version_number
  );

--
--
  -- Call After Process User Hook
  --
  begin


 PQH_DE_LEVEL_CODES_BK2.Update_LEVEL_CODES_a
(p_effective_date                => L_Effective_Date
   ,p_level_number_id           => p_level_number_id
  ,p_level_code                 => p_level_code
  ,p_description                => p_description
  ,p_gradual_value_number       => p_gradual_value_number
  ,p_level_code_id              => p_level_code_id
  ,p_object_version_number      => p_object_version_number
  );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_LEVEL_CODES'
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

  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to Update_LEVEL_CODES;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);

  when others then
p_object_version_number :=   l_object_version_number;
    --
    -- A validation or unexpected error has occured
    --
    rollback to Update_LEVEL_CODES;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end Update_LEVEL_CODES;

--
-- ----------------------------------------------------------------------------
-- |-------------------< delete_LEVEL_CODES>------------------------------|
-- ----------------------------------------------------------------------------
procedure delete_LEVEL_CODES
  (p_validate                      in     boolean  default false
  ,p_level_code_ID                  In     Number
  ,p_object_version_number         In     number) Is   --

  -- Declare cursors and local variables
  --
  l_proc           varchar2(72) := g_package||'delete_LEVEL_CODES';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_LEVEL_CODES;
  --
  -- Call Before Process User Hook
  --
  begin
  PQH_DE_LEVEL_CODES_BK3.Delete_LEVEL_CODES_b
  (p_LEVEL_CODE_Id                  =>   p_LEVEL_CODE_Id
  ,p_object_version_number         =>   p_object_version_number);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_LEVEL_CODES'
        ,p_hook_type   => 'BP');
  end;
  --
  -- Process Logic
  --
  pqh_lcd_del.del
  (p_LEVEL_CODE_id                          =>   p_LEVEL_CODE_Id
  ,p_object_version_number                  =>   p_object_version_number
  );
  --
  -- Call After Process User Hook
  --
  begin

  PQH_DE_LEVEL_CODES_BK3.Delete_LEVEL_CODES_a
  (p_LEVEL_CODE_Id                  =>   p_LEVEL_CODE_Id
  ,p_object_version_number         =>   p_object_version_number);

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_LEVEL_CODES'
        ,p_hook_type   => 'AP');
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
    rollback to delete_LEVEL_CODES;
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
    rollback to delete_LEVEL_CODES;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_LEVEL_CODES;

end PQH_DE_LEVEL_CODES_API;

/
