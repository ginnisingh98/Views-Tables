--------------------------------------------------------
--  DDL for Package Body PQH_DE_CASE_GROUPS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_DE_CASE_GROUPS_API" as
/* $Header: pqcgnapi.pkb 115.2 2002/11/27 04:43:22 rpasapul noship $ */
--
-- Package Variables
--
  g_package  varchar2(33) := 'PQH_DE_CASE_GROUPS_API.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< Insert_CASE_GROUPS >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure Insert_CASE_GROUPS
   (p_validate                            in  boolean  default false
  ,p_effective_date                     in  date
  ,p_Case_Group_NUMBER                  In  Varchar2
  ,P_DESCRIPTION                        In  Varchar2
  ,p_Advanced_Pay_Grade		        IN  Number
  ,p_Entries_in_Minute		        In  Varchar2
  ,p_Period_Of_Prob_Advmnt              IN  Number
  ,p_Period_Of_Time_Advmnt	        IN  Number
  ,p_Advancement_To			IN  Number
  ,p_Advancement_Additional_pyt 	IN  Number
  ,p_time_advanced_pay_grade            in  number
  ,p_time_advancement_to                in  number
  ,p_business_group_id                  in  number
  ,p_time_advn_units                    in  varchar2
  ,p_prob_advn_units                    in  varchar2
  ,p_sub_csgrp_description              In  Varchar2
  ,P_CASE_GROUP_ID                      out nocopy Number
  ,p_object_version_number              out nocopy number)
   is
  --
  -- Declare cursors and local variables
  --

  l_proc  varchar2(72)    := g_package||'Insert_CASE_GROUPS';
  l_object_Version_Number PQH_DE_CASE_GROUPS.OBJECT_VERSION_NUMBER%TYPE;
  L_Effective_Date        Date;
  l_CASE_GROUP_ID         PQH_DE_CASE_GROUPS.CASE_GROUP_ID%TYPE;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint Insert_CASE_GROUPS;
  --
  -- Truncate the time portion from all IN date parameters
  --
     l_effective_date := Trunc(p_effective_Date);
  --
  -- Call Before Process User Hook
  --
  begin
   PQH_DE_CASE_GROUPS_BK1.Insert_CASE_GROUPS_b
    (p_effective_date                   => L_Effective_date
    ,p_case_group_number              => p_case_group_number
    ,p_description                    => P_DESCRIPTION
    ,p_advanced_pay_grade             => P_advanced_pay_grade
    ,p_period_of_time_advmnt          => P_period_of_time_advmnt
    ,p_advancement_to                 => p_advancement_to
    ,p_Advancement_Additional_pyt     => p_Advancement_Additional_pyt
    ,p_entries_in_minute              => p_entries_in_minute
    ,p_period_of_prob_advmnt          => p_period_of_prob_advmnt
    ,p_time_advanced_pay_grade        => p_time_advanced_pay_grade
    ,p_time_advancement_to     	      => p_time_advancement_to
    ,p_business_group_id       	      => p_business_group_id
    ,p_time_advn_units         	      => p_time_advn_units
    ,p_prob_advn_units         	      => p_prob_advn_units
    ,p_sub_csgrp_description          => p_sub_csgrp_description
    );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_CASE_GROUPS'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  --
-- Process Logic
     pqh_cgn_ins.ins
    (p_effective_date                 => p_Effective_date
    ,p_case_group_number              => p_case_group_number
    ,p_description                    => P_DESCRIPTION
    ,p_case_group_id                  => l_case_group_id
    ,p_advanced_pay_grade             => P_advanced_pay_grade
    ,p_period_of_time_advmnt          => P_period_of_time_advmnt
    ,p_advancement_to                 => p_advancement_to
    ,p_Advancement_Additional_pyt     => p_Advancement_Additional_pyt
    ,p_entries_in_minute              => p_entries_in_minute
    ,p_period_of_prob_advmnt          => p_period_of_prob_advmnt
    ,p_object_version_number          => l_OBJECT_VERSION_NUMBER
    ,p_time_advanced_pay_grade        => p_time_advanced_pay_grade
    ,p_time_advancement_to     	      => p_time_advancement_to
    ,p_business_group_id       	      => p_business_group_id
    ,p_time_advn_units         	      => p_time_advn_units
    ,p_prob_advn_units         	      => p_prob_advn_units
    ,p_sub_csgrp_description          => p_sub_csgrp_description
    );

  --
  -- Call After Process User Hook
  --
  begin


        PQH_DE_CASE_GROUPS_BK1.Insert_CASE_GROUPS_a
           (p_effective_date                 => L_Effective_Date
           ,p_CASE_GROUP_NUMBER              => p_CASE_GROUP_NUMBER
           ,P_DESCRIPTION                    => P_DESCRIPTION
           ,P_CASE_GROUP_ID                  => l_CASE_GROUP_ID
           ,p_advanced_pay_grade             => P_advanced_pay_grade
           ,p_period_of_time_advmnt          => P_period_of_time_advmnt
           ,p_advancement_to                 => p_advancement_to
           ,p_Advancement_Additional_pyt     => p_Advancement_Additional_pyt
           ,p_entries_in_minute              => p_entries_in_minute
           ,p_period_of_prob_advmnt          => p_period_of_prob_advmnt
           ,p_object_version_number          => P_object_version_number
           ,p_time_advanced_pay_grade        => p_time_advanced_pay_grade
           ,p_time_advancement_to     	     => p_time_advancement_to
           ,p_business_group_id       	     => p_business_group_id
           ,p_time_advn_units         	     => p_time_advn_units
           ,p_prob_advn_units         	     => p_prob_advn_units
           ,p_sub_csgrp_description          => p_sub_csgrp_description
           );


  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_CASE_GROUPS'
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
  P_CASE_GROUP_ID           := l_CASE_GROUP_ID;
  p_object_version_number   := l_object_version_number;

  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to Insert_CASE_GROUPS;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_CASE_GROUP_ID          := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);

  when others then
    p_CASE_GROUP_ID          := null;
    p_object_version_number  := null;
    --
    -- A validation or unexpected error has occured
    --
    rollback to Insert_CASE_GROUPS;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end Insert_CASE_GROUPS;

--
-- ----------------------------------------------------------------------------
-- |--------------------------< Update_CASE_GROUPS >--------------------------|
-- ----------------------------------------------------------------------------
Procedure Update_CASE_GROUPS
   (p_validate                     in     boolean  default false
  ,p_effective_date               in     date
  ,p_case_group_id                in     number
  ,p_object_version_number        in out nocopy number
  ,p_case_group_number            in     varchar2  default hr_api.g_varchar2
  ,p_description                  in     varchar2  default hr_api.g_varchar2
  ,p_advanced_pay_grade           in     number    default hr_api.g_number
  ,p_entries_in_minute            in     varchar2  default hr_api.g_varchar2
  ,p_period_of_prob_advmnt        in     number    default hr_api.g_number
  ,p_period_of_time_advmnt        in     number    default hr_api.g_number
  ,p_advancement_to               in     number    default hr_api.g_number
  ,p_advancement_additional_pyt   in     number    default hr_api.g_number
  ,p_time_advanced_pay_grade      in     number    default hr_api.g_number
  ,p_time_advancement_to          in     number    default hr_api.g_number
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_time_advn_units              in     varchar2  default hr_api.g_varchar2
  ,p_prob_advn_units              in     varchar2  default hr_api.g_varchar2
  ,p_sub_csgrp_description        In     Varchar2  default hr_api.g_varchar2
  ) is

  l_proc  varchar2(72)      := g_package||'Update_CASE_GROUPS';
  l_object_Version_Number   PQH_DE_CASE_GROUPS.OBJECT_VERSION_NUMBER%TYPE := P_Object_version_Number;
  L_Effective_Date          Date;

Begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint Update_CASE_GROUPS;
  --
  -- Truncate the time portion from all IN date parameters
  --
     l_effective_date := Trunc(p_effective_Date);
  --
  -- Call Before Process User Hook
  --
  begin

           PQH_DE_CASE_GROUPS_BK2.Update_CASE_GROUPS_b
           (p_effective_date                 => L_Effective_Date
           ,p_CASE_GROUP_NUMBER              => p_CASE_GROUP_NUMBER
           ,P_DESCRIPTION                    => P_DESCRIPTION
           ,P_CASE_GROUP_ID                  => p_CASE_GROUP_ID
           ,p_advanced_pay_grade             => P_advanced_pay_grade
           ,p_period_of_time_advmnt          => P_period_of_time_advmnt
           ,p_advancement_to                 => p_advancement_to
           ,p_Advancement_Additional_pyt     => p_Advancement_Additional_pyt
           ,p_entries_in_minute              => p_entries_in_minute
           ,p_period_of_prob_advmnt          => p_period_of_prob_advmnt
           ,p_object_version_number          => P_object_version_number
           ,p_time_advanced_pay_grade        => p_time_advanced_pay_grade
           ,p_time_advancement_to     	     => p_time_advancement_to
           ,p_business_group_id       	     => p_business_group_id
           ,p_time_advn_units         	     => p_time_advn_units
           ,p_prob_advn_units         	     => p_prob_advn_units
           ,p_sub_csgrp_description          => p_sub_csgrp_description
           );


 exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_CASE_GROUPS'
        ,p_hook_type   => 'BP'
        );
  end;

          pqh_cgn_upd.upd
           (p_effective_date                 => p_Effective_Date
           ,p_CASE_GROUP_NUMBER              => p_CASE_GROUP_NUMBER
           ,P_DESCRIPTION                    => P_DESCRIPTION
           ,P_CASE_GROUP_ID                  => p_CASE_GROUP_ID
           ,p_advanced_pay_grade             => P_advanced_pay_grade
           ,p_period_of_time_advmnt          => P_period_of_time_advmnt
           ,p_advancement_to                 => p_advancement_to
           ,p_Advancement_Additional_pyt     => p_Advancement_Additional_pyt
           ,p_entries_in_minute              => p_entries_in_minute
           ,p_period_of_prob_advmnt          => p_period_of_prob_advmnt
           ,p_object_version_number          => l_object_version_number
           ,p_time_advanced_pay_grade        => p_time_advanced_pay_grade
           ,p_time_advancement_to     	     => p_time_advancement_to
           ,p_business_group_id       	     => p_business_group_id
           ,p_time_advn_units         	     => p_time_advn_units
           ,p_prob_advn_units         	     => p_prob_advn_units
           ,p_sub_csgrp_description          => p_sub_csgrp_description   );
--
--
  -- Call After Process User Hook
  --
  begin


 PQH_DE_CASE_GROUPS_BK2.Update_CASE_GROUPS_a
           (p_effective_date                 => L_Effective_Date
           ,p_CASE_GROUP_NUMBER              => p_CASE_GROUP_NUMBER
           ,P_DESCRIPTION                    => P_DESCRIPTION
           ,P_CASE_GROUP_ID                  => p_CASE_GROUP_ID
           ,p_advanced_pay_grade             => P_advanced_pay_grade
           ,p_period_of_time_advmnt          => P_period_of_time_advmnt
           ,p_advancement_to                 => p_advancement_to
           ,p_Advancement_Additional_pyt     => p_Advancement_Additional_pyt
           ,p_entries_in_minute              => p_entries_in_minute
           ,p_period_of_prob_advmnt          => p_period_of_prob_advmnt
           ,p_object_version_number          => P_object_version_number
           ,p_time_advanced_pay_grade        => p_time_advanced_pay_grade
           ,p_time_advancement_to     	     => p_time_advancement_to
           ,p_business_group_id       	     => p_business_group_id
           ,p_time_advn_units         	     => p_time_advn_units
           ,p_prob_advn_units         	     => p_prob_advn_units
           ,p_sub_csgrp_description          => p_sub_csgrp_description  );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_CASE_GROUPS'
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
    rollback to Update_CASE_GROUPS;
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
    rollback to Update_CASE_GROUPS;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end Update_CASE_GROUPS;

--
-- ----------------------------------------------------------------------------
-- |-------------------< delete_CASE_GROUPS>------------------------------|
-- ----------------------------------------------------------------------------
procedure delete_CASE_GROUPS
  (p_validate                      in     boolean  default false
  ,p_CASE_GROUP_ID                 In     Number
  ,p_object_version_number         In     number) Is
 --

  -- Declare cursors and local variables
  --
  l_proc           varchar2(72) := g_package||'delete_CASE_GROUPS';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_CASE_GROUPS;
  --
  -- Call Before Process User Hook
  --
  begin
  PQH_DE_CASE_GROUPS_BK3.Delete_CASE_GROUPS_b
  (p_CASE_GROUP_Id                 =>   p_CASE_GROUP_Id
  ,p_object_version_number         =>   p_object_version_number);


  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_CASE_GROUPS'
        ,p_hook_type   => 'BP');
  end;
  --
  -- Process Logic
  --
  pqh_cgn_del.del
  (p_CASE_GROUP_id                          =>   p_CASE_GROUP_Id
  ,p_object_version_number                  =>   p_object_version_number
  );
  --
  -- Call After Process User Hook
  --
  begin

  PQH_DE_CASE_GROUPS_BK3.Delete_CASE_GROUPS_a
  (p_CASE_GROUP_Id                  =>   p_CASE_GROUP_Id
  ,p_object_version_number         =>   p_object_version_number);

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_CASE_GROUPS'
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
    rollback to delete_CASE_GROUPS;
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
    rollback to delete_CASE_GROUPS;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_CASE_GROUPS;

end PQH_DE_CASE_GROUPS_API;

/
