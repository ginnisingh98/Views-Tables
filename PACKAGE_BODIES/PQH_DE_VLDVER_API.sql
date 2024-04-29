--------------------------------------------------------
--  DDL for Package Body PQH_DE_VLDVER_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_DE_VLDVER_API" as
/* $Header: pqverapi.pkb 115.1 2002/12/09 22:40:39 rpasapul noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'PQH_DE_VLDVER_API.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< Insert_Vldtn_Vern >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure Insert_Vldtn_Vern
  (p_validate                      in  boolean  default false
  ,p_effective_date                in  date
  ,p_business_group_id             in  number
  ,p_WRKPLC_VLDTN_ID               In  Number
  ,p_VERSION_NUMBER                In  Number   Default NULL
  ,p_REMUNERATION_JOB_DESCRIPTION  In  VarChar2 Default NULL
  ,P_TARIFF_CONTRACT_CODE          In  Varchar2
  ,P_TARIFF_GROUP_CODE             In  Varchar2
  ,P_JOB_GROUP_ID                  In  Number   Default NULL
  ,P_REMUNERATION_JOB_ID           In  Number   Default NULL
  ,p_DERIVED_GRADE_ID              In  Number   Default NULL
  ,P_DERIVED_CASE_GROUP_ID         In  Number   Default NULL
  ,P_DERIVED_SUBCASGRP_ID          In  Number   Default NULL
  ,P_USER_ENTERABLE_GRADE_ID       In  Number   Default NULL
  ,P_USER_ENTERABLE_CASE_GROUP_ID  In  Number   Default NULL
  ,P_USER_ENTERABLE_SUBCASGRP_ID   In  Number   Default NULL
  ,P_FREEZE                        In  Varchar2 Default NULL
  ,p_WRKPLC_VLDTN_VER_ID           out nocopy Number
  ,p_object_version_number         out nocopy number) is


  --
  -- Declare cursors and local variables
  --

  l_proc  varchar2(500)   := g_package||'Insert_Vldtn_Vern';
  l_object_Version_Number PQH_DE_WRKPLC_VLDTNS.OBJECT_VERSION_NUMBER%TYPE;
  L_Effective_Date        Date;
  l_Wrkplc_vldtn_Ver_id   PQH_DE_WRKPLC_VLDTN_VERS.WRKPLC_VLDTN_VER_ID%TYPE;
  l_version_Number        PQH_DE_WRKPLC_VLDTN_VERS.VERSION_NUMBER%TYPE;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint Insert_Vldtn_Vern;
  --
  -- Truncate the time portion from all IN date parameters
  --
     l_effective_date := Trunc(p_effective_Date);
  --
  -- Call Before Process User Hook
  --
  Select Nvl(Max(Version_number),0) + 1 into l_Version_Number
    from Pqh_De_Wrkplc_Vldtn_vers
   where Wrkplc_Vldtn_Id = p_WRKPLC_VLDTN_ID;
  begin
   PQH_DE_VLDVER_BK1.Insert_Vldtn_Vern_b
  (p_effective_date                =>  l_Effective_Date
  ,p_business_group_id             =>  p_business_group_id
  ,P_WRKPLC_VLDTN_ID               =>  P_WRKPLC_VLDTN_ID
  ,P_VERSION_NUMBER                =>  l_Version_Number
  ,P_REMUNERATION_JOB_DESCRIPTION  =>  P_REMUNERATION_JOB_DESCRIPTION
  ,P_TARIFF_CONTRACT_CODE          =>  P_TARIFF_CONTRACT_CODE
  ,P_TARIFF_GROUP_CODE             =>  P_TARIFF_GROUP_CODE
  ,P_JOB_GROUP_ID                  =>  P_JOB_GROUP_ID
  ,P_REMUNERATION_JOB_ID           =>  P_REMUNERATION_JOB_ID
  ,P_DERIVED_GRADE_ID              =>  P_DERIVED_GRADE_ID
  ,p_DERIVED_CASE_GROUP_ID         =>  P_REMUNERATION_JOB_ID
  ,p_DERIVED_SUBCASGRP_ID          =>  p_DERIVED_SUBCASGRP_ID
  ,p_USER_ENTERABLE_GRADE_ID       =>  p_USER_ENTERABLE_GRADE_ID
  ,P_USER_ENTERABLE_CASE_GROUP_ID  =>  P_USER_ENTERABLE_CASE_GROUP_ID
  ,P_USER_ENTERABLE_SUBCASGRP_ID   =>  P_USER_ENTERABLE_SUBCASGRP_ID
  ,p_FREEZE                        =>  p_FREEZE);


  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'Insert_Vldtn_Vern'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic


     pqh_ver_ins.ins
     (p_effective_date                =>  l_Effective_Date
     ,P_WRKPLC_VLDTN_ID               =>  P_WRKPLC_VLDTN_ID
     ,P_VERSION_NUMBER                =>  l_Version_Number
     ,p_business_group_id             =>  p_business_group_id
     ,P_TARIFF_CONTRACT_CODE          =>  P_TARIFF_CONTRACT_CODE
     ,P_TARIFF_GROUP_CODE             =>  P_TARIFF_GROUP_CODE
     ,p_FREEZE                        =>  p_FREEZE
     ,P_REMUNERATION_JOB_DESCRIPTION  =>  P_REMUNERATION_JOB_DESCRIPTION
     ,P_JOB_GROUP_ID                  =>  P_JOB_GROUP_ID
     ,P_REMUNERATION_JOB_ID           =>  P_REMUNERATION_JOB_ID
     ,P_DERIVED_GRADE_ID              =>  P_DERIVED_GRADE_ID
     ,p_DERIVED_CASE_GROUP_ID         =>  P_REMUNERATION_JOB_ID
     ,p_DERIVED_SUBCASGRP_ID          =>  p_DERIVED_SUBCASGRP_ID
     ,p_USER_ENTERABLE_GRADE_ID       =>  p_USER_ENTERABLE_GRADE_ID
     ,P_USER_ENTERABLE_CASE_GROUP_ID  =>  P_USER_ENTERABLE_CASE_GROUP_ID
     ,P_USER_ENTERABLE_SUBCASGRP_ID   =>  P_USER_ENTERABLE_SUBCASGRP_ID
     ,P_Wrkplc_Vldtn_Ver_id           =>  l_Wrkplc_Vldtn_Ver_Id
     ,p_object_version_number         =>  l_object_version_Number);

  --
  -- Call After Process User Hook
  --

  begin
     PQH_DE_VLDVER_BK1.Insert_Vldtn_Vern_a
     (p_effective_date                =>  l_Effective_Date
     ,p_business_group_id             =>  p_business_group_id
     ,P_WRKPLC_VLDTN_ID               =>  P_WRKPLC_VLDTN_ID
     ,P_VERSION_NUMBER                =>  l_Version_Number
     ,P_REMUNERATION_JOB_DESCRIPTION  =>  P_REMUNERATION_JOB_DESCRIPTION
     ,P_TARIFF_CONTRACT_CODE          =>  P_TARIFF_CONTRACT_CODE
     ,P_TARIFF_GROUP_CODE             =>  P_TARIFF_GROUP_CODE
     ,P_JOB_GROUP_ID                  =>  P_JOB_GROUP_ID
     ,P_REMUNERATION_JOB_ID           =>  P_REMUNERATION_JOB_ID
     ,P_DERIVED_GRADE_ID              =>  P_DERIVED_GRADE_ID
     ,p_DERIVED_CASE_GROUP_ID         =>  P_REMUNERATION_JOB_ID
     ,p_DERIVED_SUBCASGRP_ID          =>  p_DERIVED_SUBCASGRP_ID
     ,p_USER_ENTERABLE_GRADE_ID       =>  p_USER_ENTERABLE_GRADE_ID
     ,P_USER_ENTERABLE_CASE_GROUP_ID  =>  P_USER_ENTERABLE_CASE_GROUP_ID
     ,P_USER_ENTERABLE_SUBCASGRP_ID   =>  P_USER_ENTERABLE_SUBCASGRP_ID
     ,p_FREEZE                        =>  p_FREEZE
     ,p_Wrkplc_Vldtn_Ver_Id           =>  l_Wrkplc_Vldtn_Ver_Id
     ,p_object_version_number         =>  l_object_version_Number);

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'Insert_Vldtn_Vern'
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
  p_wrkplc_vldtn_Ver_id     := l_Wrkplc_vldtn_Ver_id;
  p_object_version_number  := l_object_version_number;

  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to Insert_Vldtn_Vern;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_wrkplc_vldtn_Ver_id    := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);

  when others then
      p_wrkplc_vldtn_Ver_id    := null;
    p_object_version_number  := null;
    --
    -- A validation or unexpected error has occured
    --
    rollback to Insert_Vldtn_Vern;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end Insert_Vldtn_Vern;

--
-- ----------------------------------------------------------------------------
-- |--------------------------< Update_Vldtn_Defn >--------------------------|
-- ----------------------------------------------------------------------------

procedure Update_Vldtn_Vern
  (p_validate                      in  boolean  default false
  ,p_effective_date                in  date
  ,p_business_group_id             in  number
  ,p_WRKPLC_VLDTN_ID               In  Number   Default hr_api.g_Number
  ,P_VERSION_NUMBER                In  Number   Default hr_api.g_Number
  ,P_REMUNERATION_JOB_DESCRIPTION  In  VarChar2 Default hr_api.g_Varchar2
  ,P_TARIFF_CONTRACT_CODE          In  Varchar2 Default hr_api.g_VArchar2
  ,P_TARIFF_GROUP_CODE             In  Varchar2 Default hr_api.g_Varchar2
  ,P_JOB_GROUP_ID                  In  Number   Default hr_api.g_Number
  ,P_REMUNERATION_JOB_ID           In  Number   Default hr_api.g_Number
  ,P_DERIVED_GRADE_ID              In  Number   Default hr_api.g_Number
  ,P_DERIVED_CASE_GROUP_ID         In  Number   Default hr_api.g_Number
  ,P_DERIVED_SUBCASGRP_ID          In  Number   Default hr_api.g_Number
  ,P_USER_ENTERABLE_GRADE_ID       In  Number   Default hr_api.g_Number
  ,P_USER_ENTERABLE_CASE_GROUP_ID  In  Number   Default hr_api.g_Number
  ,P_USER_ENTERABLE_SUBCASGRP_ID   In  Number   Default hr_api.g_Number
  ,P_FREEZE                        In  Varchar2 Default hr_api.g_Varchar2
  ,p_WRKPLC_VLDTN_VER_ID           In  Number
  ,p_object_version_number         in out nocopy number) Is

  l_proc  varchar2(72)    := g_package||'Update_Vldtn_Vern';
  l_object_Version_Number PQH_DE_WRKPLC_VLDTN_VERS.OBJECT_VERSION_NUMBER%TYPE := P_Object_version_Number;
  L_Effective_Date        Date;

Begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint Update_Vldtn_Vern;
  --
  -- Truncate the time portion from all IN date parameters
  --
     l_effective_date := Trunc(p_effective_Date);
  --
  -- Call Before Process User Hook
  --
  begin

  PQH_DE_VLDVER_BK2.Update_Vldtn_Vern_b
  (p_effective_date                => l_Effective_Date
  ,p_business_group_id             => p_business_group_id
  ,P_WRKPLC_VLDTN_ID               => P_WRKPLC_VLDTN_ID
  ,P_VERSION_NUMBER                => P_VERSION_NUMBER
  ,P_REMUNERATION_JOB_DESCRIPTION  => P_REMUNERATION_JOB_DESCRIPTION
  ,P_TARIFF_CONTRACT_CODE          => P_TARIFF_CONTRACT_CODE
  ,P_TARIFF_GROUP_CODE             => P_TARIFF_GROUP_CODE
  ,P_JOB_GROUP_ID                  => P_JOB_GROUP_ID
  ,P_REMUNERATION_JOB_ID           => P_REMUNERATION_JOB_ID
  ,P_DERIVED_GRADE_ID              => P_DERIVED_GRADE_ID
  ,P_DERIVED_CASE_GROUP_ID         => P_DERIVED_CASE_GROUP_ID
  ,P_DERIVED_SUBCASGRP_ID          => P_DERIVED_SUBCASGRP_ID
  ,P_USER_ENTERABLE_GRADE_ID       => P_USER_ENTERABLE_GRADE_ID
  ,P_USER_ENTERABLE_CASE_GROUP_ID  => P_USER_ENTERABLE_CASE_GROUP_ID
  ,P_USER_ENTERABLE_SUBCASGRP_ID   => P_USER_ENTERABLE_SUBCASGRP_ID
  ,P_FREEZE                        => P_FREEZE
  ,p_WRKPLC_VLDTN_VER_ID           => p_Wrkplc_Vldtn_ver_Id
  ,p_object_version_number         => l_Object_Version_Number);

exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'Update_Vldtn_Vern'
        ,p_hook_type   => 'BP'
        );
  end;

  pqh_ver_upd.upd
  (p_effective_date                => l_Effective_Date
  ,p_business_group_id             => p_business_group_id
  ,P_WRKPLC_VLDTN_ID               => P_WRKPLC_VLDTN_ID
  ,P_VERSION_NUMBER                => P_VERSION_NUMBER
  ,P_REMUNERATION_JOB_DESCRIPTION  => P_REMUNERATION_JOB_DESCRIPTION
  ,P_TARIFF_CONTRACT_CODE          => P_TARIFF_CONTRACT_CODE
  ,P_TARIFF_GROUP_CODE             => P_TARIFF_GROUP_CODE
  ,P_JOB_GROUP_ID                  => P_JOB_GROUP_ID
  ,P_REMUNERATION_JOB_ID           => P_REMUNERATION_JOB_ID
  ,P_DERIVED_GRADE_ID              => P_DERIVED_GRADE_ID
  ,P_DERIVED_CASE_GROUP_ID         => P_DERIVED_CASE_GROUP_ID
  ,P_DERIVED_SUBCASGRP_ID          => P_DERIVED_SUBCASGRP_ID
  ,P_USER_ENTERABLE_GRADE_ID       => P_USER_ENTERABLE_GRADE_ID
  ,P_USER_ENTERABLE_CASE_GROUP_ID  => P_USER_ENTERABLE_CASE_GROUP_ID
  ,P_USER_ENTERABLE_SUBCASGRP_ID   => P_USER_ENTERABLE_SUBCASGRP_ID
  ,P_FREEZE                        => P_FREEZE
  ,p_WRKPLC_VLDTN_VER_ID           => p_Wrkplc_Vldtn_ver_Id
  ,p_object_version_number         => l_Object_Version_Number);

--
--
  -- Call After Process User Hook
  --
  begin
  PQH_DE_VLDVER_BK2.Update_Vldtn_Vern_a
  (p_effective_date                => l_Effective_Date
  ,p_business_group_id             => p_business_group_id
  ,P_WRKPLC_VLDTN_ID               => P_WRKPLC_VLDTN_ID
  ,P_VERSION_NUMBER                => P_VERSION_NUMBER
  ,P_REMUNERATION_JOB_DESCRIPTION  => P_REMUNERATION_JOB_DESCRIPTION
  ,P_TARIFF_CONTRACT_CODE          => P_TARIFF_CONTRACT_CODE
  ,P_TARIFF_GROUP_CODE             => P_TARIFF_GROUP_CODE
  ,P_JOB_GROUP_ID                  => P_JOB_GROUP_ID
  ,P_REMUNERATION_JOB_ID           => P_REMUNERATION_JOB_ID
  ,P_DERIVED_GRADE_ID              => P_DERIVED_GRADE_ID
  ,P_DERIVED_CASE_GROUP_ID         => P_DERIVED_CASE_GROUP_ID
  ,P_DERIVED_SUBCASGRP_ID          => P_DERIVED_SUBCASGRP_ID
  ,P_USER_ENTERABLE_GRADE_ID       => P_USER_ENTERABLE_GRADE_ID
  ,P_USER_ENTERABLE_CASE_GROUP_ID  => P_USER_ENTERABLE_CASE_GROUP_ID
  ,P_USER_ENTERABLE_SUBCASGRP_ID   => P_USER_ENTERABLE_SUBCASGRP_ID
  ,P_FREEZE                        => P_FREEZE
  ,p_WRKPLC_VLDTN_VER_ID           => p_Wrkplc_Vldtn_ver_Id
  ,p_object_version_number         => l_Object_Version_Number);


  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'Update_Vldtn_Vern'
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
    rollback to Update_Vldtn_Vern;
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
    rollback to Update_Vldtn_Vern;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end Update_Vldtn_Vern;

--
-- ----------------------------------------------------------------------------
-- |-------------------< delete_Vldtn_Defn>------------------------------|
-- ----------------------------------------------------------------------------
procedure delete_Vldtn_Vern
  (p_validate                      in     boolean  default false
  ,p_WRKPLC_VLDTN_Ver_ID           In     Number
  ,p_object_version_number         In     number) Is   --

  -- Declare cursors and local variables
  --
  l_proc           varchar2(72) := g_package||'delete_Vldtn_Vern';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_Vldtn_Vern;
  --
  -- Call Before Process User Hook
  --
  begin
  PQH_DE_VLDVER_BK3.Delete_Vldtn_Vern_b
  (p_WRKPLC_VLDTN_VERID            =>   p_WRKPLC_VLDTN_VER_ID
  ,p_object_version_number         =>   p_object_version_number);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_Vldtn_Vern'
        ,p_hook_type   => 'BP');
  end;
  --
  -- Process Logic
  --
  pqh_ver_del.del
    (p_WRKPLC_VLDTN_Ver_ID          =>  p_WRKPLC_VLDTN_VER_ID
    ,p_object_version_number        =>  p_object_version_number);
  --
  -- Call After Process User Hook
  --
  begin

   PQH_DE_VLDVER_BK3.Delete_Vldtn_Vern_a
  (p_WRKPLC_VLDTN_VER_ID                => p_WRKPLC_VLDTN_VER_ID
  ,p_object_version_number              => p_object_version_number);

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_Vldtn_Vern'
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
    rollback to delete_Vldtn_Vern;
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
    rollback to delete_Vldtn_Vern;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_Vldtn_Vern;

end PQH_DE_VLDVER_API;

/
