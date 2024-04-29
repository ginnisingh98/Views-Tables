--------------------------------------------------------
--  DDL for Package Body PQH_DE_INS_END_REASONS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_DE_INS_END_REASONS_API" as
/* $Header: pqpreapi.pkb 115.1 2002/12/03 20:42:04 rpasapul noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'PQH_DE_iNs_END_REASONS_API.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< Insert_PENSION_END_REASONS >------------------|
-- ----------------------------------------------------------------------------
--
procedure Insert_PENSION_END_REASONS
 ( p_validate                       in     boolean  default false
  ,p_effective_date                 in     date
  ,p_business_group_id              in     number
  ,p_provider_organization_id       in     number
  ,p_end_reason_number              in     varchar2
  ,p_end_reason_short_name          in     varchar2
  ,p_end_reason_description         in     varchar2
  ,p_InS_end_reason_id          out nocopy    number
  ,p_object_version_number          out nocopy    number
  )  is
  --
  -- Declare cursors and local variables
  --

  l_proc  varchar2(72)    := g_package||'Insert_PENSION_END_REASONS';
  l_object_Version_Number PQH_DE_INS_END_REASONS.OBJECT_VERSION_NUMBER%TYPE;
  L_Effective_Date        Date;
  l_INS_end_reason_id PQH_DE_INS_END_REASONS.INS_end_reason_id%TYPE;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint Insert_PENSION_END_REASONS;
  --
  -- Truncate the time portion from all IN date parameters
  --
     l_effective_date := Trunc(p_effective_Date);
  --
  -- Call Before Process User Hook
  --
  begin


   PQH_DE_ins_END_REASONS_BK1.Insert_PENSION_END_REASONS_b
   (p_effective_date             => L_Effective_Date
   ,p_business_group_id          => p_business_group_id
   ,P_provider_organization_id   => P_provider_organization_id
   ,p_end_reason_number          => p_end_reason_number
   , p_end_reason_short_name     => p_end_reason_short_name
   ,p_end_reason_description     => p_end_reason_description
);


  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_PENSION_END_REASONS'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --

  -- Process Logic
     pqh_pre_ins.ins
    (p_business_group_id          => p_business_group_id
    ,P_provider_organization_id   => P_provider_organization_id
    ,p_end_reason_number          => p_end_reason_number
    , p_end_reason_short_name     => p_end_reason_short_name
    ,p_end_reason_description     => p_end_reason_description
    ,p_InS_end_reason_id      => l_INS_end_reason_id
    ,p_object_version_number      => l_object_version_number
    );

  --
  -- Call After Process User Hook
  --
  begin


        PQH_DE_ins_END_REASONS_BK1.Insert_PENSION_END_REASONS_a
        (p_effective_date             => L_Effective_Date
        ,p_business_group_id          => p_business_group_id
        ,P_provider_organization_id   => P_provider_organization_id
        ,p_end_reason_number          => p_end_reason_number
        , p_end_reason_short_name     => p_end_reason_short_name
        ,p_end_reason_description     => p_end_reason_description
        ,p_InS_end_reason_id      => p_INS_end_reason_id
        ,p_object_version_number      => p_object_version_number
        );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'INSERT_PENSION_END_REASONS'
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
  p_InS_end_reason_id   := l_INS_end_reason_id ;
  p_object_version_number   := l_object_version_number;

  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to Insert_PENSION_END_REASONS;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_InS_end_reason_id     := null;
    p_object_version_number     := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);

  when others then
    p_InS_end_reason_id     := null;
    p_object_version_number     := null;
    --
    -- A validation or unexpected error has occured
    --
    rollback to Insert_PENSION_END_REASONS;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end Insert_PENSION_END_REASONS;

--
-- ----------------------------------------------------------------------------
-- |--------------------------< Update_PENSION_END_REASONS >------------------|
-- ----------------------------------------------------------------------------

procedure Update_PENSION_END_REASONS
 ( p_validate                      in     boolean  default false
  ,p_effective_date               in     date
  ,p_InS_end_reason_id        in     number
  ,p_object_version_number        in out nocopy number
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_provider_organization_id     in     number    default hr_api.g_number
  ,p_end_reason_number            in     varchar2  default hr_api.g_varchar2
  ,p_end_reason_short_name        in     varchar2  default hr_api.g_varchar2
  ,p_end_reason_description       in     varchar2  default hr_api.g_varchar2
  ) Is

  l_proc  varchar2(72)      := g_package||'Update_PENSION_END_REASONS';
  l_object_Version_Number   PQH_DE_INS_END_REASONS.OBJECT_VERSION_NUMBER%TYPE := P_Object_version_Number;
  L_Effective_Date          Date;

Begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint Update_PENSION_END_REASONS;
  --
  -- Truncate the time portion from all IN date parameters
  --
     l_effective_date := Trunc(p_effective_Date);
  --
  -- Call Before Process User Hook
  --
  begin


PQH_DE_ins_END_REASONS_BK2.Update_PENSION_END_REASONS_b
        (p_effective_date             => L_Effective_Date
        ,p_business_group_id          => p_business_group_id
        ,P_provider_organization_id   => P_provider_organization_id
        ,p_end_reason_number          => p_end_reason_number
        , p_end_reason_short_name     => p_end_reason_short_name
        ,p_end_reason_description     => p_end_reason_description
        ,p_InS_end_reason_id      => p_INS_end_reason_id
        ,p_object_version_number      => p_object_version_number
        );


 exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_PENSION_END_REASONS'
        ,p_hook_type   => 'BP'
        );
  end;

pqh_pre_upd.upd
        (p_business_group_id          => p_business_group_id
        ,P_provider_organization_id   => P_provider_organization_id
        ,p_end_reason_number          => p_end_reason_number
        , p_end_reason_short_name     => p_end_reason_short_name
        ,p_end_reason_description     => p_end_reason_description
        ,p_InS_end_reason_id      => p_INS_end_reason_id
        ,p_object_version_number      => l_object_version_number
        );


--
--
  -- Call After Process User Hook
  --
  begin


 PQH_DE_ins_END_REASONS_BK2.Update_PENSION_END_REASONS_a
       (p_effective_date              => L_Effective_Date
        ,p_business_group_id          => p_business_group_id
        ,P_provider_organization_id   => P_provider_organization_id
        ,p_end_reason_number          => p_end_reason_number
        , p_end_reason_short_name     => p_end_reason_short_name
        ,p_end_reason_description     => p_end_reason_description
        ,p_InS_end_reason_id      => p_INS_end_reason_id
        ,p_object_version_number      => p_object_version_number
        );


  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_PENSION_END_REASONS'
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
    rollback to Update_PENSION_END_REASONS;
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
    rollback to Update_PENSION_END_REASONS;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end Update_PENSION_END_REASONS;

--
-- ----------------------------------------------------------------------------
-- |-------------------< delete_PENSION_END_REASONS>--------------------------
-- ----------------------------------------------------------------------------
procedure delete_PENSION_END_REASONS
   (p_validate                      in     boolean  default false
  ,p_InS_end_reason_id       In     Number
  ,p_object_version_number         In     number) is

  -- Declare cursors and local variables
  --
  l_proc           varchar2(72) := g_package||'delete_PENSION_END_REASONS';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_PENSION_END_REASONS;
  --
  -- Call Before Process User Hook
  --
  begin
  PQH_DE_ins_END_REASONS_BK3.Delete_PENSION_END_REASONS_b
  (p_InS_end_reason_id             =>   p_INS_END_REASON_Id
  ,p_object_version_number         =>   p_object_version_number);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_PENSION_END_REASONS'
        ,p_hook_type   => 'BP');
  end;
  --
  -- Process Logic
  --
  pqh_pre_del.del
  (p_InS_end_reason_id                      =>   p_INS_END_REASON_Id
  ,p_object_version_number                  =>   p_object_version_number
  );
  --
  -- Call After Process User Hook
  --
  begin

  PQH_DE_ins_END_REASONS_BK3.Delete_PENSION_END_REASONS_a
  (p_InS_end_reason_id         =>   p_iNs_END_REASON_Id
  ,p_object_version_number         =>   p_object_version_number);

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_PENSION_END_REASONS'
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
    rollback to delete_PENSION_END_REASONS;
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
    rollback to delete_PENSION_END_REASONS;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_PENSION_END_REASONS;

end PQH_DE_ins_END_REASONS_API;

/
