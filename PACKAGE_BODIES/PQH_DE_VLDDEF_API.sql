--------------------------------------------------------
--  DDL for Package Body PQH_DE_VLDDEF_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_DE_VLDDEF_API" as
/* $Header: pqdefapi.pkb 115.1 2002/12/09 22:40:19 rpasapul noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'PQH_DE_VLDDEF_API.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< Insert_Vldtn_Defn >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure Insert_Vldtn_Defn
  (p_validate                      in  boolean  default false
  ,p_effective_date                in  date
  ,p_business_group_id             in  number
  ,p_VALIDATION_NAME               In  Varchar2
  ,p_EMPLOYMENT_TYPE               In  Varchar2
  ,p_REMUNERATION_REGULATION       In  Varchar2
  ,p_WRKPLC_VLDTN_ID               out nocopy number
  ,p_object_version_number         out nocopy number) is
  --
  -- Declare cursors and local variables
  --

  l_proc  varchar2(72)    := g_package||'Insert_Vldtn_Defn';
  l_object_Version_Number PQH_DE_WRKPLC_VLDTNs.OBJECT_VERSION_NUMBER%TYPE;
  L_Effective_Date        Date;
  l_Wrkplc_vldtn_id       PQH_DE_WRKPLC_VLDTNS.WRKPLC_VLDTN_ID%TYPE;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint Insert_Vldtn_Defn;
  --
  -- Truncate the time portion from all IN date parameters
  --
     l_effective_date := Trunc(p_effective_Date);
  --
  -- Call Before Process User Hook
  --
  begin
    PQH_DE_VLDDEF_BK1.Insert_Vldtn_Defn_b
      (p_effective_date           => l_effective_date
      ,p_business_group_id        => p_business_group_Id
      ,p_VALIDATION_NAME          => p_VALIDATION_NAME
      ,p_EMPLOYMENT_TYPE          => p_EMPLOYMENT_TYPE
      ,p_REMUNERATION_REGULATION  => p_REMUNERATION_REGULATION);

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'Insert_Vldtn_Defn'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
     pqh_def_ins.ins
     (p_effective_date            => l_effective_date
     ,p_business_group_id         => p_business_group_id
     ,p_VALIDATION_NAME           => p_VALIDATION_NAME
     ,p_EMPLOYMENT_TYPE           => p_EMPLOYMENT_TYPE
     ,p_REMUNERATION_REGULATION   => p_remuneration_Regulation
     ,p_WRKPLC_VLDTN_ID           => l_Wrkplc_Vldtn_id
     ,p_object_version_number     => l_object_version_Number);
  --
  -- Call After Process User Hook
  --
  begin
  PQH_DE_VLDDEF_BK1.Insert_Vldtn_Defn_a
  (p_effective_date               => l_effective_date
  ,p_business_group_id            => p_business_group_id
  ,p_VALIDATION_NAME              => p_VALIDATION_NAME
  ,p_EMPLOYMENT_TYPE              => p_EMPLOYMENT_TYPE
  ,p_REMUNERATION_REGULATION      => p_REMUNERATION_REGULATION
  ,p_WRKPLC_VLDTN_ID              => l_WRKPLC_VLDTN_ID
  ,p_object_version_number        => l_object_version_Number);

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'Insert_Vldtn_Defn'
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
  p_wrkplc_vldtn_id        := l_Wrkplc_vldtn_id;
  p_object_version_number  := l_object_version_number;

  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to Insert_Vldtn_Defn;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_wrkplc_vldtn_id        := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);

  when others then
      p_wrkplc_vldtn_id        := null;
    p_object_version_number  := null;
    --
    -- A validation or unexpected error has occured
    --
    rollback to Insert_Vldtn_Defn;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end Insert_Vldtn_Defn;

--
-- ----------------------------------------------------------------------------
-- |--------------------------< Update_Vldtn_Defn >--------------------------|
-- ----------------------------------------------------------------------------

procedure Update_Vldtn_Defn
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_business_group_id             in     number   Default hr_api.g_Number
  ,p_VALIDATION_NAME               In     Varchar2 Default hr_api.g_Varchar2
  ,p_EMPLOYMENT_TYPE               In     Varchar2 Default hr_api.g_Varchar2
  ,p_REMUNERATION_REGULATION       In     Varchar2 Default hr_api.g_Varchar2
  ,p_WRKPLC_VLDTN_ID               In     number
  ,p_object_version_number         In out nocopy number) Is

  l_proc  varchar2(72)    := g_package||'Update_Vldtn_Defn';
  l_object_Version_Number PQH_DE_WRKPLC_VLDTNs.OBJECT_VERSION_NUMBER%TYPE := P_Object_version_Number;
  L_Effective_Date        Date;

Begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint Update_Vldtn_Defn;
  --
  -- Truncate the time portion from all IN date parameters
  --
     l_effective_date := Trunc(p_effective_Date);
  --
  -- Call Before Process User Hook
  --
  begin

  PQH_DE_VLDDEF_BK2.Update_Vldtn_Defn_b
  (p_effective_date              => l_effective_date
  ,p_business_group_id           => p_business_group_id
  ,p_VALIDATION_NAME             => p_Validation_name
  ,p_EMPLOYMENT_TYPE             => P_employment_type
  ,p_REMUNERATION_REGULATION     => p_remuneration_Regulation
  ,p_WRKPLC_VLDTN_ID             => p_Wrkplc_vldtn_id
  ,p_object_version_number       => l_Object_Version_number);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'Update_Vldtn_Defn'
        ,p_hook_type   => 'BP'
        );
  end;

  pqh_def_upd.upd
  (p_effective_date               => L_effective_date
  ,p_wrkplc_vldtn_id              => P_wrkplc_Vldtn_id
  ,p_validation_name              => p_validation_name
  ,p_business_group_id            => p_business_group_id
  ,p_employment_type              => p_employment_type
  ,p_remuneration_regulation      => p_remuneration_regulation
  ,p_object_version_number        => l_object_version_number);

--
--
  -- Call After Process User Hook
  --
  begin
  PQH_DE_VLDDEF_BK2.Update_Vldtn_Defn_a
  (p_effective_date              => l_effective_date
  ,p_business_group_id           => p_business_group_id
  ,p_VALIDATION_NAME             => p_VALIDATION_NAME
  ,p_EMPLOYMENT_TYPE             => p_EMPLOYMENT_TYPE
  ,p_REMUNERATION_REGULATION     => p_REMUNERATION_REGULATION
  ,p_WRKPLC_VLDTN_ID             => p_WRKPLC_VLDTN_ID
  ,p_object_version_number       => l_Object_Version_Number);


  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'Update_Vldtn_Defn'
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
    rollback to Update_Vldtn_Defn;
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
    rollback to Update_Vldtn_Defn;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end Update_Vldtn_Defn;

--
-- ----------------------------------------------------------------------------
-- |-------------------< delete_Vldtn_Defn>------------------------------|
-- ----------------------------------------------------------------------------
procedure delete_Vldtn_Defn
  (p_validate                      in     boolean  default false
  ,p_WRKPLC_VLDTN_ID               In     Number
  ,p_object_version_number         In     number) Is   --

  -- Declare cursors and local variables
  --
  l_proc           varchar2(72) := g_package||'delete_Vldtn_Defn';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_Vldtn_Defn;
  --
  -- Call Before Process User Hook
  --
  begin
  PQH_DE_VLDDEF_BK3.Delete_Vldtn_Defn_b
  (p_WRKPLC_VLDTN_ID               =>   p_WRKPLC_VLDTN_ID
  ,p_object_version_number         =>   p_object_version_number);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_Vldtn_Defn'
        ,p_hook_type   => 'BP');
  end;
  --
  -- Process Logic
  --
  pqh_def_del.del
    (p_WRKPLC_VLDTN_ID               =>  p_WRKPLC_VLDTN_ID
    ,p_object_version_number         =>  p_object_version_number);
  --
  -- Call After Process User Hook
  --
  begin

   PQH_DE_VLDDEF_BK3.Delete_Vldtn_Defn_a
  (p_WRKPLC_VLDTN_ID                => p_WRKPLC_VLDTN_ID
  ,p_object_version_number          => p_object_version_number);

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_Vldtn_Defn'
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
    rollback to delete_Vldtn_Defn;
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
    rollback to delete_Vldtn_Defn;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_Vldtn_Defn;

end PQH_DE_VLDDEF_API;

/
