--------------------------------------------------------
--  DDL for Package Body PQH_DE_LEVEL_NUMBERS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_DE_LEVEL_NUMBERS_API" as
/* $Header: pqgvnapi.pkb 115.1 2002/11/27 23:43:53 rpasapul noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'PQH_DE_LEVEL_NUMBERS_API.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< Insert_LEVEL_NUMBERS >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure Insert_LEVEL_NUMBERS
  (p_validate                      in  boolean  default false
  ,p_effective_date                in  date
  ,p_LEVEL_NUMBER                  In  Varchar2
  ,P_DESCRIPTION                   In  Varchar2
  ,P_LEVEL_NUMBER_ID               out nocopy Number
  ,p_object_version_number         out nocopy number) is
  --
  -- Declare cursors and local variables
  --

  l_proc  varchar2(72)    := g_package||'Insert_LEVEL_NUMBERS';
  l_object_Version_Number PQH_DE_LEVEL_NUMBERS.OBJECT_VERSION_NUMBER%TYPE;
  L_Effective_Date        Date;
  l_LEVEL_NUMBER_ID       PQH_DE_LEVEL_NUMBERS.LEVEL_NUMBER_ID%TYPE;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint Insert_LEVEL_NUMBERS;
  --
  -- Truncate the time portion from all IN date parameters
  --
     l_effective_date := Trunc(p_effective_Date);
  --
  -- Call Before Process User Hook
  --
  begin
   PQH_DE_LEVEL_NUMBERS_BK1.Insert_LEVEL_NUMBERS_b
   (p_effective_date             => L_Effective_Date
   ,p_LEVEL_NUMBER               => p_LEVEL_NUMBER
   ,P_DESCRIPTION                => P_DESCRIPTION);


  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_LEVEL_NUMBERS'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
     pqh_gvn_ins.ins
    (p_effective_date               => l_Effective_date
    ,p_LEVEL_NUMBER                 => p_LEVEL_NUMBER
    ,p_description                  => P_DESCRIPTION
    ,p_LEVEL_NUMBER_id              => l_LEVEL_NUMBER_id
    ,p_object_version_number        => l_OBJECT_VERSION_NUMBER
    );

  --
  -- Call After Process User Hook
  --
  begin


        PQH_DE_LEVEL_NUMBERS_BK1.Insert_LEVEL_NUMBERS_a
           (p_effective_date             => L_Effective_Date
           ,p_LEVEL_NUMBER               => p_LEVEL_NUMBER
           ,P_DESCRIPTION                => P_DESCRIPTION
           ,P_LEVEL_NUMBER_ID            => l_LEVEL_NUMBER_ID
           ,p_object_version_number      => l_object_version_number);

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_LEVEL_NUMBERS'
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
  P_LEVEL_NUMBER_ID         := l_LEVEL_NUMBER_ID;
  p_object_version_number   := l_object_version_number;

  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to Insert_LEVEL_NUMBERS;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_LEVEL_NUMBER_ID        := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);

  when others then
    p_LEVEL_NUMBER_ID        := null;
    p_object_version_number  := null;
    --
    -- A validation or unexpected error has occured
    --
    rollback to Insert_LEVEL_NUMBERS;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end Insert_LEVEL_NUMBERS;

--
-- ----------------------------------------------------------------------------
-- |--------------------------< Update_LEVEL_NUMBERS >------------------------|
-- ----------------------------------------------------------------------------

procedure Update_LEVEL_NUMBERS
  (p_validate                      in  boolean  default false
  ,p_effective_date                in  date
  ,p_LEVEL_NUMBER                  In  Varchar2 Default hr_api.g_Varchar2
  ,P_DESCRIPTION                   In  Varchar2 Default hr_api.g_Varchar2
  ,P_LEVEL_NUMBER_ID               In  Number
  ,p_object_version_number         IN out nocopy number) Is

  l_proc  varchar2(72)      := g_package||'Update_LEVEL_NUMBERS';
  l_object_Version_Number   PQH_DE_LEVEL_NUMBERS.OBJECT_VERSION_NUMBER%TYPE := P_Object_version_Number;
  L_Effective_Date          Date;

Begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint Update_LEVEL_NUMBERS;
  --
  -- Truncate the time portion from all IN date parameters
  --
     l_effective_date := Trunc(p_effective_Date);
  --
  -- Call Before Process User Hook
  --
  begin


PQH_DE_LEVEL_NUMBERS_BK2.Update_LEVEL_NUMBERS_b
           (p_effective_date             => L_Effective_Date
           ,p_LEVEL_NUMBER               => p_LEVEL_NUMBER
           ,P_DESCRIPTION                => P_DESCRIPTION
           ,P_LEVEL_NUMBER_ID            => p_LEVEL_NUMBER_ID
           ,p_object_version_number      => l_object_version_number);


 exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_LEVEL_NUMBERS'
        ,p_hook_type   => 'BP'
        );
  end;

pqh_gvn_upd.upd
  (p_effective_date               => l_Effective_Date
  ,p_LEVEL_NUMBER_id              => p_LEVEL_NUMBER_ID
  ,p_object_version_number        => l_object_version_number
  ,p_LEVEL_NUMBER                 => p_LEVEL_NUMBER
  ,p_description                  => P_DESCRIPTION  ) ;

--
--
  -- Call After Process User Hook
  --
  begin


 PQH_DE_LEVEL_NUMBERS_BK2.Update_LEVEL_NUMBERS_a
           (p_effective_date             => L_Effective_Date
           ,p_LEVEL_NUMBER               => p_LEVEL_NUMBER
           ,P_DESCRIPTION                => P_DESCRIPTION
           ,P_LEVEL_NUMBER_ID            => p_LEVEL_NUMBER_ID
           ,p_object_version_number      => l_object_version_number);

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_LEVEL_NUMBERS'
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
    rollback to Update_LEVEL_NUMBERS;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);

  when others then
  p_object_version_number := l_object_version_number;
    --
    -- A validation or unexpected error has occured
    --
    rollback to Update_LEVEL_NUMBERS;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end Update_LEVEL_NUMBERS;

--
-- ----------------------------------------------------------------------------
-- |-------------------< delete_LEVEL_NUMBERS >------------------------------|
-- ----------------------------------------------------------------------------
procedure delete_LEVEL_NUMBERS
  (p_validate                      in     boolean  default false
  ,p_LEVEL_NUMBER_ID               In     Number
  ,p_object_version_number         In     number) Is

--

  -- Declare cursors and local variables
  --
  l_proc           varchar2(72) := g_package||'delete_LEVEL_NUMBERS';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_LEVEL_NUMBERS;
  --
  -- Call Before Process User Hook
  --
  begin



  PQH_DE_LEVEL_NUMBERS_BK3.Delete_LEVEL_NUMBERS_b
  (p_LEVEL_NUMBER_Id           =>   p_LEVEL_NUMBER_Id
  ,p_object_version_number     =>   p_object_version_number);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_LEVEL_NUMBERS'
        ,p_hook_type   => 'BP');
  end;
  --
  -- Process Logic
  --
  pqh_gvn_del.del
  (p_LEVEL_NUMBER_id                        =>   p_LEVEL_NUMBER_Id
  ,p_object_version_number                  =>   p_object_version_number
  );
  --
  -- Call After Process User Hook
  --
  begin

  PQH_DE_LEVEL_NUMBERS_BK3.Delete_LEVEL_NUMBERS_a
  (p_LEVEL_NUMBER_Id               =>   p_LEVEL_NUMBER_Id
  ,p_object_version_number         =>   p_object_version_number);

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_LEVEL_NUMBERS'
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
    rollback to delete_LEVEL_NUMBERS;
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
    rollback to delete_LEVEL_NUMBERS;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_LEVEL_NUMBERS;

end PQH_DE_LEVEL_NUMBERS_API;

/
