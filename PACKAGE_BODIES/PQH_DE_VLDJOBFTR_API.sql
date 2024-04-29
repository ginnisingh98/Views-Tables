--------------------------------------------------------
--  DDL for Package Body PQH_DE_VLDJOBFTR_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_DE_VLDJOBFTR_API" as
/* $Header: pqftrapi.pkb 115.1 2002/11/27 23:43:34 rpasapul noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'PQH_DE_VLDJOBTR_API.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< Insert_Vldtn_JobFTRS >------------------------|
-- ----------------------------------------------------------------------------
--
procedure Insert_Vldtn_JobFtr
  (p_validate                      in  boolean  default false
  ,p_effective_date                in  date
  ,p_business_group_id             in  number
  ,P_WRKPLC_VLDTN_OPR_JOB_ID       In  Number
  ,P_JOB_FEATURE_Code              In  Varchar2
  ,P_Wrkplc_Vldtn_Opr_job_Type     In  Varchar2
  ,P_WRKPLC_VLDTN_JOBFTR_ID        out nocopy Number
  ,p_object_version_number         out nocopy number) is
  --
  -- Declare cursors and local variables
  --

  l_proc  varchar2(72)       := g_package||'Insert_Vldtn_Jobftr';
  l_object_Version_Number    PQH_DE_WRKPLC_VLDTN_JOBFTRS.OBJECT_VERSION_NUMBER%TYPE;
  L_Effective_Date           Date;
  l_Wrkplc_vldtn_JOBFTR_id   PQH_DE_WRKPLC_VLDTN_JOBFTRS.WRKPLC_VLDTN_JOBFTR_ID%TYPE;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint Insert_Vldtn_JobFtr;
  --
  -- Truncate the time portion from all IN date parameters
  --
     l_effective_date := Trunc(p_effective_Date);
  --
  -- Call Before Process User Hook
  --
  begin
   PQH_DE_VLDJOBFTR_BK1.Insert_Vldtn_JobFtr_b
   (p_effective_date             => L_Effective_Date
   ,p_business_group_id          => p_Business_Group_Id
   ,P_WRKPLC_VLDTN_OPR_JOB_ID    => P_Wrkplc_Vldtn_Opr_Job_Id
   ,P_JOB_FEATURE_CODE           => P_Job_Feature_Code
   ,P_Wrkplc_Vldtn_Opr_job_Type  => P_Wrkplc_Vldtn_Opr_Job_Type);


  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'Insert_Vldtn_JobFtr'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
     pqh_Ftr_ins.ins
     (P_EFFECTIVE_DATE               => l_Effective_date
     ,P_WRKPLC_VLDTN_OPR_JOB_ID      => p_Wrkplc_Vldtn_OPR_JOB_Id
     ,P_JOB_FEATURE_CODE             => P_JOB_FEATURE_CODE
     ,P_BUSINESS_GROUP_ID            => P_BUSINESS_GROUP_ID
     ,P_Wrkplc_Vldtn_Opr_job_Type    => P_Wrkplc_Vldtn_Opr_Job_Type
     ,P_WRKPLC_VLDTN_JOBFTR_ID       => l_WRKPLC_VLDTN_JOBFTR_ID
     ,P_OBJECT_VERSION_NUMBER        => l_OBJECT_VERSION_NUMBER);

  --
  -- Call After Process User Hook
  --
  begin
     PQH_DE_VLDJOBFTR_BK1.Insert_Vldtn_JobFtr_a
     (p_effective_date               => l_Effective_Date
     ,p_business_group_id            => p_Business_group_Id
     ,p_WRKPLC_VLDTN_OPR_JOB_ID      => p_WRKPLC_VLDTN_OPR_JOB_ID
     ,p_Job_Feature_Code             => p_Job_feature_Code
     ,P_Wrkplc_Vldtn_Opr_job_Type    => P_Wrkplc_Vldtn_Opr_Job_Type
     ,P_WRKPLC_VLDTN_JOBFTR_ID       => l_WRKPLC_VLDTN_JOBFTR_ID
     ,p_object_version_number        => l_object_version_number);

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'Insert_Vldtn_Jobftr'
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
  p_wrkplc_vldtn_Jobftr_id := l_Wrkplc_vldtn_Jobftr_id;
  p_object_version_number  := l_object_version_number;

  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to Insert_Vldtn_jobftr;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_wrkplc_vldtn_Jobftr_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);

  when others then
    p_wrkplc_vldtn_Jobftr_id := null;
    p_object_version_number  := null;
    --
    -- A validation or unexpected error has occured
    --
    rollback to Insert_Vldtn_Jobftr;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end Insert_Vldtn_Jobftr;

--
-- ----------------------------------------------------------------------------
-- |--------------------------< Update_Vldtn_Jobftr >--------------------------|
-- ----------------------------------------------------------------------------

procedure Update_Vldtn_Jobftr
  (p_validate                      in  boolean  default false
  ,p_effective_date                in  date
  ,p_business_group_id             in  number   Default hr_api.g_Number
  ,P_WRKPLC_VLDTN_OPR_JOB_ID       In  Number   Default hr_api.g_Number
  ,p_JOB_FEATURE_CODE              In  Varchar2 Default hr_api.g_Varchar2
  ,P_Wrkplc_Vldtn_Opr_job_Type     In  Varchar2 Default hr_api.g_Varchar2
  ,P_WRKPLC_VLDTN_JOBFTR_ID        In  Number
  ,p_object_version_number         In  out nocopy number) Is

  l_proc  varchar2(72)    := g_package||'Update_Vldtn_Jobftr';
  l_object_Version_Number PQH_DE_WRKPLC_VLDTN_Jobftrs.OBJECT_VERSION_NUMBER%TYPE := P_Object_version_Number;
  L_Effective_Date        Date;

Begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint Update_Vldtn_JObFtr;
  --
  -- Truncate the time portion from all IN date parameters
  --
     l_effective_date := Trunc(p_effective_Date);
  --
  -- Call Before Process User Hook
  --
  begin

   PQH_DE_VLDJOBftr_BK2.Update_Vldtn_Jobftr_b
  (p_effective_date                => l_Effective_Date
  ,p_business_group_id             => p_business_group_id
  ,p_WRKPLC_VLDTN_OPR_JOB_ID       => p_Wrkplc_Vldtn_OPR_JOB_Id
  ,P_Job_Feature_Code              => P_Job_Feature_Code
  ,P_Wrkplc_Vldtn_Opr_job_Type     => P_Wrkplc_Vldtn_Opr_Job_Type
  ,P_WRKPLC_VLDTN_JOBFTR_ID        => P_WRKPLC_VLDTN_JOBFTR_ID
  ,p_object_version_number         => l_object_version_number);

 exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'Update_Vldtn_Jobftr'
        ,p_hook_type   => 'BP'
        );
  end;

  pqh_ftr_upd.upd
  (P_EFFECTIVE_DATE       	  => l_Effective_Date
  ,P_WRKPLC_VLDTN_JOBFTR_ID       => P_WRKPLC_VLDTN_JOBFTR_ID
  ,P_OBJECT_VERSION_NUMBER        => l_OBJECT_VERSION_NUMBER
  ,P_WRKPLC_VLDTN_OPR_JOB_ID      => P_WRKPLC_VLDTN_OPR_JOB_ID
  ,P_JOB_FEATURE_CODE             => P_JOB_FEATURE_CODE
  ,P_BUSINESS_GROUP_ID            => P_BUSINESS_GROUP_ID
  ,P_Wrkplc_Vldtn_Opr_job_Type    => P_Wrkplc_Vldtn_Opr_Job_Type);

--
--
  -- Call After Process User Hook
  --
  begin

   PQH_DE_VLDJOBFTR_BK2.Update_Vldtn_JOBFTR_a
  (p_effective_date                => l_Effective_Date
  ,p_business_group_id             => p_business_group_id
  ,p_WRKPLC_VLDTN_OPR_JOB_ID       => p_Wrkplc_Vldtn_OPR_JOB_Id
  ,P_JOB_FEATURE_CODE              => P_JOB_FEATURE_CODE
  ,P_Wrkplc_Vldtn_Opr_job_Type     => P_Wrkplc_Vldtn_Opr_Job_Type
  ,P_WRKPLC_VLDTN_JOBFTR_ID        => P_WRKPLC_VLDTN_JOBFTR_ID
  ,p_object_version_number         => l_object_version_number);

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'Update_Vldtn_Jobftr'
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
    rollback to Update_Vldtn_Jobftr;
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
    rollback to Update_Vldtn_Jobftr;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end Update_Vldtn_Jobftr;

--
-- ----------------------------------------------------------------------------
-- |-------------------< delete_Vldtn_Jobftr>------------------------------|
-- ----------------------------------------------------------------------------
procedure delete_Vldtn_Jobftr
  (p_validate                      in     boolean  default false
  ,p_WRKPLC_VLDTN_JOBFTR_ID        In     Number
  ,p_object_version_number         In     number) Is   --

  -- Declare cursors and local variables
  --
  l_proc           varchar2(72) := g_package||'delete_Vldtn_Jobftr';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_Vldtn_Jobftr;
  --
  -- Call Before Process User Hook
  --
  begin
  PQH_DE_VLDJOBFTR_BK3.Delete_Vldtn_JobFTR_b
  (p_WRKPLC_VLDTN_JOBFTR_ID        =>   p_WRKPLC_VLDTN_JOBFTR_ID
  ,p_object_version_number         =>   p_object_version_number);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_Vldtn_Jobftr'
        ,p_hook_type   => 'BP');
  end;
  --
  -- Process Logic
  --
  pqh_ftr_del.del
    (p_WRKPLC_VLDTN_JOBFTR_ID       =>  p_WRKPLC_VLDTN_JOBFTR_ID
    ,p_object_version_number        =>  p_object_version_number);
  --
  -- Call After Process User Hook
  --
  begin

   PQH_DE_VLDJOBFTR_BK3.Delete_Vldtn_Jobftr_a
  (p_WRKPLC_VLDTN_JOBFTR_ID         => p_WRKPLC_VLDTN_JOBFTR_ID
  ,p_object_version_number          => p_object_version_number);

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_Vldtn_Jobftr'
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
    rollback to delete_Vldtn_Jobftr;
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
    rollback to delete_Vldtn_Jobftr;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_Vldtn_Jobftr;

end PQH_DE_VLDJOBftr_API;

/
