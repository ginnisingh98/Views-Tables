--------------------------------------------------------
--  DDL for Package Body PQH_DE_ENT_MINUTES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_DE_ENT_MINUTES_API" as
/* $Header: pqetmapi.pkb 115.1 2002/11/27 23:43:16 rpasapul noship $ */
--
-- Package Variables
--
  g_package  varchar2(33) := 'PQH_DE_ENT_MINUTES_API.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< Insert_ENT_MINUTES >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure Insert_ENT_MINUTES
  (p_validate                            in  boolean  default false
  ,p_effective_date                      in  date
  ,p_TARIFF_Group_CD                     In  Varchar2
  ,p_ent_minutes_CD                      In  Varchar2
  ,P_DESCRIPTION                         In  Varchar2
  ,p_business_group_id                   in  number
  ,P_ENT_MINUTES_ID                      out nocopy Number
  ,p_object_version_number               out nocopy number) is
  --
  -- Declare cursors and local variables
  --

  l_proc  varchar2(72)    := g_package||'Insert_ENT_MINUTES';
  l_object_Version_Number PQH_DE_ENT_MINUTES.OBJECT_VERSION_NUMBER%TYPE;
  L_Effective_Date        Date;
  l_ENT_MINUTES_ID        PQH_DE_ENT_MINUTES.ENT_MINUTES_ID%TYPE;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint Insert_ENT_MINUTES;
  --
  -- Truncate the time portion from all IN date parameters
  --
     l_effective_date := Trunc(p_effective_Date);
  --
  -- Call Before Process User Hook
  --
  begin
   PQH_DE_ENT_MINUTES_BK1.Insert_ENT_MINUTES_b
    (p_effective_date                 => L_Effective_date
    ,p_ent_minutes_CD                 => p_ent_minutes_CD
    ,P_ENT_MINUTES_ID                 => l_ENT_MINUTES_ID
    ,p_TARIFF_Group_CD                => p_TARIFF_Group_CD
    ,p_description                    => P_DESCRIPTION
    ,p_business_group_id       	      => p_business_group_id
    );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_ENT_MINUTES'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  --
-- Process Logic
     pqh_etm_ins.ins
    (p_effective_date                  => p_Effective_date
    ,p_TARIFF_Group_CD                => p_TARIFF_Group_CD
    ,p_ent_minutes_CD                 => p_ent_minutes_CD
    ,p_description                     => P_DESCRIPTION
    ,p_ENT_MINUTES_ID                  => l_ENT_MINUTES_ID
    ,p_object_version_number           => l_OBJECT_VERSION_NUMBER
    ,p_business_group_id       	       => p_business_group_id
    );

  --
  -- Call After Process User Hook
  --
  begin


        PQH_DE_ENT_MINUTES_BK1.Insert_ENT_MINUTES_a
           (p_effective_date                 => L_Effective_date
            ,P_ENT_MINUTES_ID                  => l_ENT_MINUTES_ID
            ,p_ent_minutes_CD                 => p_ent_minutes_CD
            ,p_TARIFF_Group_CD                => p_TARIFF_Group_CD
            ,p_description                    => P_DESCRIPTION
            ,p_business_group_id       	      => p_business_group_id
           );


  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_ENT_MINUTES'
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
  P_ENT_MINUTES_ID           := l_ENT_MINUTES_ID;
  p_object_version_number   := l_object_version_number;

  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to Insert_ENT_MINUTES;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_ENT_MINUTES_ID          := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);

  when others then
    p_ent_minutes_id         := null;
    p_object_version_number  := null;
    --
    -- A validation or unexpected error has occured
    --
    rollback to Insert_ENT_MINUTES;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end Insert_ENT_MINUTES;

--
-- ----------------------------------------------------------------------------
-- |--------------------------< Update_ENT_MINUTES >--------------------------|
-- ----------------------------------------------------------------------------
  Procedure Update_ENT_MINUTES
  (p_validate                       in     boolean  default false
  ,p_effective_date                 in     date
  ,p_ENT_MINUTES_ID                 in     number
  ,p_object_version_number          in     out nocopy number
  ,p_TARIFF_Group_CD                in     varchar2  default hr_api.g_varchar2
  ,p_ent_minutes_CD                 In      Varchar2     default hr_api.g_varchar2
  ,p_description                    in     varchar2  default hr_api.g_varchar2
  ,p_business_group_id              in     number    default hr_api.g_number
  ) is

  l_proc  varchar2(72)      := g_package||'Update_ENT_MINUTES';
  l_object_Version_Number   PQH_DE_ENT_MINUTES.OBJECT_VERSION_NUMBER%TYPE := P_Object_version_Number;
  L_Effective_Date          Date;

Begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint Update_ENT_MINUTES;
  --
  -- Truncate the time portion from all IN date parameters
  --
     l_effective_date := Trunc(p_effective_Date);
  --
  -- Call Before Process User Hook
  --
  begin

           PQH_DE_ENT_MINUTES_BK2.Update_ENT_MINUTES_b
           (p_effective_date                 => L_Effective_date
            ,P_ENT_MINUTES_ID                => P_ENT_MINUTES_ID
            ,p_TARIFF_Group_CD               => p_TARIFF_Group_CD
            ,p_ent_minutes_CD                => p_ent_minutes_CD
            ,p_description                   => P_DESCRIPTION
            ,p_business_group_id       	     => p_business_group_id
           );

 exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_ENT_MINUTES'
        ,p_hook_type   => 'BP'
        );
  end;

   pqh_etm_upd.upd
    (p_effective_date                  => p_Effective_date
    ,p_TARIFF_Group_CD                 => p_TARIFF_Group_CD
    ,p_ent_minutes_CD                  => p_ent_minutes_CD
    ,p_description                     => P_DESCRIPTION
    ,p_ENT_MINUTES_ID                  => P_ENT_MINUTES_ID
    ,p_object_version_number           => l_OBJECT_VERSION_NUMBER
    ,p_business_group_id       	       => p_business_group_id
    );
--
--
  -- Call After Process User Hook
  --
  begin


 PQH_DE_ENT_MINUTES_BK2.Update_ENT_MINUTES_a
          (p_effective_date                  => L_Effective_date
            ,P_ENT_MINUTES_ID                => P_ENT_MINUTES_ID
            ,p_ent_minutes_CD                 => p_ent_minutes_CD
            ,p_TARIFF_Group_CD               => p_TARIFF_Group_CD
            ,p_description                   => P_DESCRIPTION
            ,p_business_group_id       	     => p_business_group_id
           );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_ENT_MINUTES'
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
    rollback to Update_ENT_MINUTES;
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
    rollback to Update_ENT_MINUTES;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end Update_ENT_MINUTES;

--
-- ----------------------------------------------------------------------------
-- |-------------------< delete_ENT_MINUTES>------------------------------|
-- ----------------------------------------------------------------------------
procedure delete_ENT_MINUTES
  (p_validate                      in     boolean  default false
  ,p_ENT_MINUTES_ID                 In     Number
  ,p_object_version_number         In     number) Is
 --

  -- Declare cursors and local variables
  --
  l_proc           varchar2(72) := g_package||'delete_ENT_MINUTES';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_ENT_MINUTES;
  --
  -- Call Before Process User Hook
  --
  begin
  PQH_DE_ENT_MINUTES_BK3.Delete_ENT_MINUTES_b
  (p_ENT_MINUTES_ID                =>   p_ENT_MINUTES_ID
  ,p_object_version_number         =>   p_object_version_number);


  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_ENT_MINUTES'
        ,p_hook_type   => 'BP');
  end;
  --
  -- Process Logic
  --
  pqh_etm_del.del
  (p_ENT_MINUTES_ID                         =>   p_ENT_MINUTES_ID
  ,p_object_version_number                  =>   p_object_version_number
  );
  --
  -- Call After Process User Hook
  --
  begin

  PQH_DE_ENT_MINUTES_BK3.Delete_ENT_MINUTES_a
  (p_ENT_MINUTES_ID                  =>   p_ENT_MINUTES_ID
  ,p_object_version_number         =>   p_object_version_number);

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_ENT_MINUTES'
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
    rollback to delete_ENT_MINUTES;
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
    rollback to delete_ENT_MINUTES;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_ENT_MINUTES;

end PQH_DE_ENT_MINUTES_API;

/
