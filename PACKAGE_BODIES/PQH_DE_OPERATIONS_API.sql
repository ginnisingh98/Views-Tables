--------------------------------------------------------
--  DDL for Package Body PQH_DE_OPERATIONS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_DE_OPERATIONS_API" as
/* $Header: pqoplapi.pkb 115.1 2002/12/03 00:09:25 rpasapul noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'PQH_DE_OPERATIONS_API.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< Insert_OPERATIONS >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure Insert_OPERATIONS
  (p_validate                      in  boolean  default false
  ,p_effective_date                in  date
  ,p_OPERATION_NUMBER              In  Varchar2 Default NULL
  ,P_DESCRIPTION                   In  Varchar2
  ,P_OPERATION_ID                  out nocopy Number
  ,p_object_version_number         out nocopy number) is
  --
  -- Declare cursors and local variables
  --

  l_proc  varchar2(72)    := g_package||'Insert_OPERATIONS';
  l_object_Version_Number PQH_DE_OPERATIONS.OBJECT_VERSION_NUMBER%TYPE;
  L_Effective_Date        Date;
  l_OPERATION_ID          PQH_DE_OPERATIONS.OPERATION_ID%TYPE;

  l_operation_Number      PQH_DE_OPERATIONS.OPERATION_NUMBER%TYPE;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint Insert_OPERATIONS;
  --
  -- Truncate the time portion from all IN date parameters
  --
     l_effective_date := Trunc(p_effective_Date);
  --
  -- Call Before Process User Hook
  --

  begin
   PQH_DE_OPERATIONS_BK1.Insert_OPERATIONS_b
   (p_effective_date             => L_Effective_Date
   ,p_OPERATION_NUMBER           => l_OPERATION_NUMBER
   ,P_DESCRIPTION                => P_DESCRIPTION );


  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_OPERATIONS'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
     pqh_opl_ins.ins
    (p_effective_date               => l_Effective_date
    ,p_OPERATION_number             => p_OPERATION_number
    ,p_description                  => P_DESCRIPTION
    ,p_OPERATION_id                 => l_OPERATION_id
    ,p_object_version_number        => l_OBJECT_VERSION_NUMBER
    );

  --
  -- Call After Process User Hook
  --
  begin


        PQH_DE_OPERATIONS_BK1.Insert_OPERATIONS_a
           (p_effective_date             => L_Effective_Date
           ,p_OPERATION_NUMBER           => l_OPERATION_NUMBER
           ,P_DESCRIPTION                => P_DESCRIPTION
           ,P_OPERATION_ID               => l_OPERATION_ID
           ,p_object_version_number      => l_object_version_number);


  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'INSERT_OPERATIONS'
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
  P_OPERATION_ID            := l_OPERATION_ID;
  p_object_version_number   := l_object_version_number;

  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to Insert_OPERATIONS;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_OPERATION_ID    := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);

  when others then
    p_OPERATION_ID    := null;
    p_object_version_number  := null;
    --
    -- A validation or unexpected error has occured
    --
    rollback to Insert_OPERATIONS;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end Insert_OPERATIONS;

--
-- ----------------------------------------------------------------------------
-- |--------------------------< Update_OPERATIONS >--------------------------|
-- ----------------------------------------------------------------------------

procedure Update_OPERATIONS
  (p_validate                      in  boolean  default false
  ,p_effective_date                in  date
  ,p_OPERATION_NUMBER              In  Varchar2 Default hr_api.g_Varchar2
  ,P_DESCRIPTION                   In  Varchar2 Default hr_api.g_Varchar2
  ,P_OPERATION_ID                  In  Number
  ,p_object_version_number         in  out nocopy number) Is

  l_proc  varchar2(72)      := g_package||'Update_OPERATIONS';
  l_object_Version_Number   PQH_DE_OPERATIONS.OBJECT_VERSION_NUMBER%TYPE := P_Object_version_Number;
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


PQH_DE_OPERATIONS_BK2.Update_OPERATIONS_b
           (p_effective_date             => L_Effective_Date
           ,p_OPERATION_NUMBER           => p_OPERATION_NUMBER
           ,P_DESCRIPTION                => P_DESCRIPTION
           ,P_OPERATION_ID               => p_OPERATION_ID
           ,p_object_version_number      => l_object_version_number);


 exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_OPERATIONS'
        ,p_hook_type   => 'BP'
        );
  end;

pqh_opl_upd.upd
  (p_effective_date               => l_Effective_Date
  ,p_OPERATION_id                 => p_OPERATION_ID
  ,p_object_version_number        => l_object_version_number
  ,p_OPERATION_number             => p_OPERATION_NUMBER
  ,p_description                  => P_DESCRIPTION  ) ;

--
--
  -- Call After Process User Hook
  --
  begin


 PQH_DE_OPERATIONS_BK2.Update_OPERATIONS_a
           (p_effective_date             => L_Effective_Date
           ,p_OPERATION_NUMBER           => p_OPERATION_NUMBER
           ,P_DESCRIPTION                => P_DESCRIPTION
           ,P_OPERATION_ID               => p_OPERATION_ID
           ,p_object_version_number      => l_object_version_number);

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_OPERATIONS'
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
    rollback to Update_OPERATIONS;
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
    rollback to Update_OPERATIONS;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end Update_OPERATIONS;

--
-- ----------------------------------------------------------------------------
-- |-------------------< delete_OPERATIONS>------------------------------|
-- ----------------------------------------------------------------------------
procedure delete_OPERATIONS
  (p_validate                      in     boolean  default false
  ,p_OPERATION_ID                  In     Number
  ,p_object_version_number         In     number) Is   --

  -- Declare cursors and local variables
  --
  l_proc           varchar2(72) := g_package||'delete_OPERATIONS';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_OPERATIONS;
  --
  -- Call Before Process User Hook
  --
  begin
  PQH_DE_OPERATIONS_BK3.Delete_OPERATIONS_b
  (p_OPERATION_Id                  =>   p_OPERATION_Id
  ,p_object_version_number         =>   p_object_version_number);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_OPERATIONS'
        ,p_hook_type   => 'BP');
  end;
  --
  -- Process Logic
  --
  pqh_opl_del.del
  (p_OPERATION_id                           =>   p_OPERATION_Id
  ,p_object_version_number                  =>   p_object_version_number
  );
  --
  -- Call After Process User Hook
  --
  begin

  PQH_DE_OPERATIONS_BK3.Delete_OPERATIONS_a
  (p_OPERATION_Id                  =>   p_OPERATION_Id
  ,p_object_version_number         =>   p_object_version_number);

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_OPERATIONS'
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
    rollback to delete_OPERATIONS;
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
    rollback to delete_OPERATIONS;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_OPERATIONS;

end PQH_DE_OPERATIONS_API;

/
