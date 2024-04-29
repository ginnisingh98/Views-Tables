--------------------------------------------------------
--  DDL for Package Body PQH_DE_VLDJOB_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_DE_VLDJOB_API" as
/* $Header: pqwvjapi.pkb 115.1 2002/12/05 00:32:17 rpasapul noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'PQH_DE_VLDJOB_API.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< Insert_Vldtn_Job >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure Insert_Vldtn_Job
  (p_validate                      in  boolean  default false
  ,p_effective_date                in  date
  ,p_business_group_id             in  number
  ,P_WRKPLC_VLDTN_OP_ID            In  Number
  ,P_WRKPLC_JOB_ID                 In  Number
  ,P_DESCRIPTION                   In  Varchar2
  ,P_WRKPLC_VLDTN_JOB_ID           out nocopy Number
  ,p_object_version_number         out nocopy number) is
  --
  -- Declare cursors and local variables
  --

  l_proc  varchar2(72)    := g_package||'Insert_Vldtn_Job';
  l_object_Version_Number PQH_DE_WRKPLC_VLDTN_JOBS.OBJECT_VERSION_NUMBER%TYPE;
  L_Effective_Date        Date;
  l_Wrkplc_vldtn_JOB_id   PQH_DE_WRKPLC_VLDTN_JOBS.WRKPLC_VLDTN_JOB_ID%TYPE;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint Insert_Vldtn_Job;
  --
  -- Truncate the time portion from all IN date parameters
  --
     l_effective_date := Trunc(p_effective_Date);
  --
  -- Call Before Process User Hook
  --
  begin
   PQH_DE_VLDJOB_BK1.Insert_Vldtn_Job_b
   (p_effective_date             => L_Effective_Date
   ,p_business_group_id          => p_Business_Group_Id
   ,P_WRKPLC_VLDTN_OP_ID         => P_Wrkplc_Vldtn_Op_Id
   ,P_WRKPLC_JOB_ID              => P_Wrkplc_Job_Id
   ,P_DESCRIPTION                => P_Description);


  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'Insert_Vldtn_Job'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
     pqh_job_ins.ins
     (P_EFFECTIVE_DATE               => l_Effective_date
     ,P_WRKPLC_VLDTN_OP_ID           => p_Wrkplc_Vldtn_OP_Id
     ,P_WRKPLC_JOB_ID                => P_WRKPLC_JOB_ID
     ,P_BUSINESS_GROUP_ID            => P_BUSINESS_GROUP_ID
     ,P_DESCRIPTION                  => P_DESCRIPTION
     ,P_WRKPLC_VLDTN_JOB_ID          => l_WRKPLC_VLDTN_JOB_ID
     ,P_OBJECT_VERSION_NUMBER        => l_OBJECT_VERSION_NUMBER);

  --
  -- Call After Process User Hook
  --
  begin
     PQH_DE_VLDJOB_BK1.Insert_Vldtn_Job_a
     (p_effective_date               => l_Effective_Date
     ,p_business_group_id            => p_Business_group_Id
     ,p_WRKPLC_VLDTN_OP_ID           => p_WRKPLC_VLDTN_OP_ID
     ,p_WRKPLC_JOB_ID                => p_WRKPLC_JOB_ID
     ,P_DESCRIPTION                  => P_DESCRIPTION
     ,P_WRKPLC_VLDTN_JOB_ID          => l_WRKPLC_VLDTN_JOB_ID
     ,p_object_version_number        => l_object_version_number);

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'Insert_Vldtn_Job'
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
  p_wrkplc_vldtn_Job_id     := l_Wrkplc_vldtn_Job_id;
  p_object_version_number   := l_object_version_number;

  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to Insert_Vldtn_job;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_wrkplc_vldtn_Job_id    := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);

  when others then
    p_wrkplc_vldtn_Job_id    := null;
    p_object_version_number  := null;
    --
    -- A validation or unexpected error has occured
    --
    rollback to Insert_Vldtn_Job;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end Insert_Vldtn_Job;

--
-- ----------------------------------------------------------------------------
-- |--------------------------< Update_Vldtn_Job >--------------------------|
-- ----------------------------------------------------------------------------

procedure Update_Vldtn_Job
  (p_validate                      in  boolean  default false
  ,p_effective_date                in  date
  ,p_business_group_id             in  number   Default hr_api.g_Number
  ,P_WRKPLC_VLDTN_OP_ID            In  Number   Default hr_api.g_Number
  ,P_WRKPLC_JOB_ID                 In  Number   Default hr_api.g_Number
  ,P_DESCRIPTION                   In  Varchar2 Default hr_api.g_Varchar2
  ,P_WRKPLC_VLDTN_JOB_ID           In  Number
  ,p_object_version_number         In  out nocopy number) Is

  l_proc  varchar2(72)    := g_package||'Update_Vldtn_Job';
  l_object_Version_Number PQH_DE_WRKPLC_VLDTN_JobS.OBJECT_VERSION_NUMBER%TYPE := P_Object_version_Number;
  L_Effective_Date        Date;

Begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint Update_Vldtn_Oprn;
  --
  -- Truncate the time portion from all IN date parameters
  --
     l_effective_date := Trunc(p_effective_Date);
  --
  -- Call Before Process User Hook
  --
  begin

   PQH_DE_VLDJOB_BK2.Update_Vldtn_Job_b
  (p_effective_date                => l_Effective_Date
  ,p_business_group_id             => p_business_group_id
  ,p_WRKPLC_VLDTN_OP_ID            => p_Wrkplc_Vldtn_OP_Id
  ,P_WRKPLC_JOB_ID                 => P_WRKPLC_JOB_ID
  ,P_DESCRIPTION                   => P_DESCRIPTION
  ,P_WRKPLC_VLDTN_JOB_ID           => P_WRKPLC_VLDTN_JOB_ID
  ,p_object_version_number         => l_object_version_number);

 exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'Update_Vldtn_Job'
        ,p_hook_type   => 'BP'
        );
  end;

  pqh_Job_upd.upd
  (P_EFFECTIVE_DATE       	  => l_Effective_Date
  ,P_WRKPLC_VLDTN_JOB_ID          => P_WRKPLC_VLDTN_JOB_ID
  ,P_OBJECT_VERSION_NUMBER        => l_OBJECT_VERSION_NUMBER
  ,P_WRKPLC_VLDTN_OP_ID           => P_WRKPLC_VLDTN_OP_ID
  ,P_WRKPLC_JOB_ID                => P_WRKPLC_JOB_ID
  ,P_BUSINESS_GROUP_ID            => P_BUSINESS_GROUP_ID
  ,P_DESCRIPTION                  => P_DESCRIPTION);

--
--
  -- Call After Process User Hook
  --
  begin

   PQH_DE_VLDJOB_BK2.Update_Vldtn_JOB_a
  (p_effective_date                => l_Effective_Date
  ,p_business_group_id             => p_business_group_id
  ,p_WRKPLC_VLDTN_OP_ID            => p_Wrkplc_Vldtn_OP_Id
  ,P_WRKPLC_JOB_ID                 => P_WRKPLC_JOB_ID
  ,P_DESCRIPTION                   => P_DESCRIPTION
  ,P_WRKPLC_VLDTN_JOB_ID           => P_WRKPLC_VLDTN_JOB_ID
  ,p_object_version_number         => l_object_version_number);

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'Update_Vldtn_Job'
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
    rollback to Update_Vldtn_Job;
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
    rollback to Update_Vldtn_Job;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end Update_Vldtn_Job;

--
-- ----------------------------------------------------------------------------
-- |-------------------< delete_Vldtn_Job>------------------------------|
-- ----------------------------------------------------------------------------
procedure delete_Vldtn_Job
  (p_validate                      in     boolean  default false
  ,p_WRKPLC_VLDTN_JOB_ID           In     Number
  ,p_object_version_number         In     number) Is   --

  -- Declare cursors and local variables
  --
  l_proc           varchar2(72) := g_package||'delete_Vldtn_Job';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_Vldtn_Job;
  --
  -- Call Before Process User Hook
  --
  begin
  PQH_DE_VLDJOB_BK3.Delete_Vldtn_Job_b
  (p_WRKPLC_VLDTN_JOB_ID           =>   p_WRKPLC_VLDTN_JOB_ID
  ,p_object_version_number         =>   p_object_version_number);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_Vldtn_Job'
        ,p_hook_type   => 'BP');
  end;
  --
  -- Process Logic
  --
  pqh_JOb_del.del
    (p_WRKPLC_VLDTN_JOB_ID          =>  p_WRKPLC_VLDTN_JOB_ID
    ,p_object_version_number        =>  p_object_version_number);
  --
  -- Call After Process User Hook
  --
  begin

   PQH_DE_VLDJOB_BK3.Delete_Vldtn_Job_a
  (p_WRKPLC_VLDTN_JOB_ID            => p_WRKPLC_VLDTN_JOB_ID
  ,p_object_version_number          => p_object_version_number);

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_Vldtn_Job'
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
    rollback to delete_Vldtn_Job;
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
    rollback to delete_Vldtn_Job;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_Vldtn_Job;

end PQH_DE_VLDJOB_API;

/
