--------------------------------------------------------
--  DDL for Package Body PQH_DE_RESULT_SETS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_DE_RESULT_SETS_API" as
/* $Header: pqrssapi.pkb 115.1 2002/12/03 20:43:18 rpasapul noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'PQH_DE_RESULT_SETS_API.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< Insert_RESULT_SETS >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure Insert_RESULT_SETS
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_gradual_value_number_from     in     number
  ,p_gradual_value_number_to       in     number
  ,p_grade_id                      in     number
  ,p_result_set_id                 out nocopy    number
  ,p_object_version_number         out nocopy    number
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc  varchar2(72)    := g_package||'Insert_RESULT_SETS';
  l_object_Version_Number PQH_DE_RESULT_SETS.OBJECT_VERSION_NUMBER%TYPE;
  L_Effective_Date        Date;
  l_RESULT_SET_ID         PQH_DE_RESULT_SETS.RESULT_SET_ID%TYPE;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --


      savepoint Insert_RESULT_SETS;
  --
  -- Truncate the time portion from all IN date parameters
  --
     l_effective_date := Trunc(p_effective_Date);
  --
  -- Call Before Process User Hook
  --
  begin
   PQH_DE_RESULT_SETS_BK1.Insert_RESULT_SETS_b
   (p_effective_date             => L_Effective_Date
   ,p_gradual_value_number_from  => p_gradual_value_number_from
   ,p_gradual_value_number_to    => p_gradual_value_number_to
   ,P_grade_id                   => P_grade_id  );


  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_RESULT_SETS'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --

  -- Process Logic
     pqh_rss_ins.ins
    (p_effective_date               => l_Effective_date
    ,p_gradual_value_number_from    => p_gradual_value_number_from
    ,p_gradual_value_number_to      => p_gradual_value_number_to
    ,p_grade_id                     => p_grade_id
    ,p_result_set_id                => l_result_set_id
    ,p_object_version_number        => l_OBJECT_VERSION_NUMBER
    );

  --
  -- Call After Process User Hook
  --
  begin


        PQH_DE_RESULT_SETS_BK1.Insert_RESULT_SETS_a
           (p_effective_date               => l_Effective_date
           ,p_gradual_value_number_from    => p_gradual_value_number_from
           ,p_gradual_value_number_to      => p_gradual_value_number_to
           ,p_grade_id                     => p_grade_id
           ,p_result_set_id                => p_result_set_id
           ,p_object_version_number        => l_OBJECT_VERSION_NUMBER  );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_RESULT_SETS'
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
  P_RESULT_SET_ID           := l_RESULT_SET_ID;
  p_object_version_number   := l_object_version_number;

  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
     rollback to Insert_RESULT_SETS;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_RESULT_SET_ID          := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);

  when others then
      p_RESULT_SET_ID          := null;
    p_object_version_number  := null;
    --
    -- A validation or unexpected error has occured
    --
    rollback to Insert_RESULT_SETS;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end Insert_RESULT_SETS;

--
-- ----------------------------------------------------------------------------
-- |--------------------------< Update_RESULT_SETS >--------------------------|
-- ----------------------------------------------------------------------------

procedure Update_RESULT_SETS
  (p_validate                      in  boolean  default false
,p_effective_date               in     date
  ,p_result_set_id                in     number
  ,p_object_version_number        in out nocopy number
  ,p_gradual_value_number_from    in     number    default hr_api.g_number
  ,p_gradual_value_number_to      in     number    default hr_api.g_number
  ,p_grade_id                     in     number    default hr_api.g_number
  ) is

  l_proc  varchar2(72)      := g_package||'Update_RESULT_SETS';
  l_object_Version_Number   PQH_DE_RESULT_SETS.OBJECT_VERSION_NUMBER%TYPE := P_Object_version_Number;
  L_Effective_Date          Date;

Begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint Update_RESULT_SETS;
  --
  -- Truncate the time portion from all IN date parameters
  --
     l_effective_date := Trunc(p_effective_Date);
  --
  -- Call Before Process User Hook
  --
  begin

PQH_DE_RESULT_SETS_BK2.Update_RESULT_SETS_b
     (p_effective_date              => L_Effective_Date
      ,p_gradual_value_number_from  => p_gradual_value_number_from
      ,p_gradual_value_number_to    => p_gradual_value_number_to
      ,P_grade_id                   => P_grade_id
      ,P_RESULT_SET_ID              => p_RESULT_SET_ID
      ,p_object_version_number      => p_object_version_number);


 exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_TATIGKEIT_DETAILS'
        ,p_hook_type   => 'BP'
        );
  end;

   pqh_rss_upd.upd
      (p_effective_date              => L_Effective_Date
      ,p_gradual_value_number_from  => p_gradual_value_number_from
      ,p_gradual_value_number_to    => p_gradual_value_number_to
      ,P_grade_id                   => P_grade_id
      ,P_RESULT_SET_ID              => p_RESULT_SET_ID
      ,p_object_version_number      => l_object_version_number);

--
--
  -- Call After Process User Hook
  --
  begin


 PQH_DE_RESULT_SETS_BK2.Update_RESULT_SETS_a
     (p_effective_date              => L_Effective_Date
      ,p_gradual_value_number_from  => p_gradual_value_number_from
      ,p_gradual_value_number_to    => p_gradual_value_number_to
      ,P_grade_id                   => P_grade_id
      ,P_RESULT_SET_ID              => p_RESULT_SET_ID
      ,p_object_version_number      => p_object_version_number);

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_RESULT_SETS'
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
    rollback to Update_RESULT_SETS;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);

  when others then
    p_object_version_number  := l_object_version_number;
    --
    -- A validation or unexpected error has occured
    --
    rollback to Update_RESULT_SETS;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end Update_RESULT_SETS;

--
-- ----------------------------------------------------------------------------
-- |-------------------< delete_RESULT_SETS >------------------------------|
-- ----------------------------------------------------------------------------
procedure delete_RESULT_SETS
  (p_validate                 in     boolean  default false
   ,p_RESULT_SET_ID           In     Number
  ,p_object_version_number    In     number) is

 --

  -- Declare cursors and local variables
  --
  l_proc           varchar2(72) := g_package||'delete_RESULT_SETS';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_RESULT_SETS;
  --
  -- Call Before Process User Hook
  --
  begin
  PQH_DE_RESULT_SETS_BK3.Delete_RESULT_SETS_b
  (p_RESULT_SET_Id                 =>   p_RESULT_SET_Id
  ,p_object_version_number         =>   p_object_version_number);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_RESULT_SETS'
        ,p_hook_type   => 'BP');
  end;
  --
  -- Process Logic
  --
  pqh_rss_del.del
  (p_RESULT_SET_id                          =>   p_RESULT_SET_Id
  ,p_object_version_number                  =>   p_object_version_number
  );
  --
  -- Call After Process User Hook
  --
  begin

  PQH_DE_RESULT_SETS_BK3.Delete_RESULT_SETS_a
  (p_RESULT_SET_Id                 =>   p_RESULT_SET_Id
  ,p_object_version_number         =>   p_object_version_number);

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_RESULT_SETS'
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
    rollback to delete_RESULT_SETS;
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
    rollback to delete_RESULT_SETS;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_RESULT_SETS;

end PQH_DE_RESULT_SETS_API;

/
