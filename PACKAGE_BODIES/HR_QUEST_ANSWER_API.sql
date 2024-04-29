--------------------------------------------------------
--  DDL for Package Body HR_QUEST_ANSWER_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_QUEST_ANSWER_API" as
/* $Header: hrqsaapi.pkb 120.0 2005/05/31 02:25:28 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_quest_answer_api.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_quest_answer >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_quest_answer
  ( p_validate                       in     boolean  default false
   ,p_effective_date                 in     date
   ,p_questionnaire_template_id      in     number
   ,p_type                           in     varchar2
   ,p_type_object_id                 in     number
   ,p_business_group_id              in     number
   ,p_questionnaire_answer_id           out nocopy number

  ) is
  --
  -- Declare cursors and local variables
  --

  l_effective_date      date;
  l_proc                varchar2(72) := g_package||'create_quest_answer';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_quest_answer;
  --
  -- Remember IN OUT parameter IN values
  --

  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);

  --
  -- Call Before Process User Hook
  --
  begin
    hr_quest_answer_bk1.create_quest_answer_b
      (
       p_effective_date            		 =>     l_effective_date
      ,p_questionnaire_template_id 		 =>     p_questionnaire_template_id
      ,p_type                      		 =>     p_type
      ,p_type_object_id            		 =>     p_type_object_id
      ,p_business_group_id         		 =>     p_business_group_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_quest_answer'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
   hr_qsa_ins.ins
   (
        p_effective_date            		 =>     l_effective_date
       ,p_questionnaire_template_id 		 =>     p_questionnaire_template_id
       ,p_type                      		 =>     p_type
       ,p_type_object_id            		 =>     p_type_object_id
       ,p_business_group_id         		 =>     p_business_group_id
       ,p_questionnaire_answer_id          	 =>     p_questionnaire_answer_id
   );
  --
  -- Call After Process User Hook
  --
  begin
    hr_quest_answer_bk1.create_quest_answer_a
      (
       p_effective_date            		 =>     l_effective_date
      ,p_questionnaire_template_id 		 =>     p_questionnaire_template_id
      ,p_type                      		 =>     p_type
      ,p_type_object_id            		 =>     p_type_object_id
      ,p_business_group_id         		 =>     p_business_group_id
      ,p_questionnaire_answer_id          	 =>     p_questionnaire_answer_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_quest_answer'
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
  -- Set all IN OUT and OUT parameters with out values
  --


  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_quest_answer;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_questionnaire_answer_id:=null;

    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_quest_answer;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_questionnaire_answer_id:=null;

    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_quest_answer;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_quest_answer >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_quest_answer
  (
    p_validate                     in     boolean  default false
   ,p_effective_date               in     date
   ,p_questionnaire_answer_id      in     number
   ,p_questionnaire_template_id    in     number    default hr_api.g_number
   ,p_type                         in     varchar2  default hr_api.g_varchar2
   ,p_type_object_id               in     number    default hr_api.g_number
   ,p_business_group_id            in     number    default hr_api.g_number

  ) is
  --
  -- Declare cursors and local variables
  --
  l_in_out_parameter    number;
  l_effective_date      date;
  l_proc                varchar2(72) := g_package||'update_quest_answer';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_quest_answer;
  --
  -- Remember IN OUT parameter IN values
  --

  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);

  --
  -- Call Before Process User Hook
  --
  begin
    hr_quest_answer_bk2.update_quest_answer_b
      (
       p_effective_date            	=>		 l_effective_date
      ,p_questionnaire_answer_id   	=>		 p_questionnaire_answer_id
      ,p_questionnaire_template_id      =>		 p_questionnaire_template_id
      ,p_type                           =>		 p_type
      ,p_type_object_id            	=>		 p_type_object_id
      ,p_business_group_id         	=>		 p_business_group_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_quest_answer'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --



  --
  -- Process Logic
  --
   hr_qsa_upd.upd
   (
       p_effective_date            	=>		 l_effective_date
      ,p_questionnaire_answer_id   	=>		 p_questionnaire_answer_id
      ,p_questionnaire_template_id      =>		 p_questionnaire_template_id
      ,p_type                           =>		 p_type
      ,p_type_object_id            	=>		 p_type_object_id
      ,p_business_group_id         	=>		 p_business_group_id
   );

  --
  -- Call After Process User Hook
  --
  begin
    hr_quest_answer_bk2.update_quest_answer_a
      (
   	  p_effective_date            	=>		 l_effective_date
   	 ,p_questionnaire_answer_id   	=>		 p_questionnaire_answer_id
   	 ,p_questionnaire_template_id   =>		 p_questionnaire_template_id
   	 ,p_type                        =>		 p_type
   	 ,p_type_object_id            	=>		 p_type_object_id
      	 ,p_business_group_id         	=>		 p_business_group_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_quest_answer'
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
  -- Set all IN OUT and OUT parameters with out values
  --


  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_quest_answer;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --

    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_quest_answer;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --

    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_quest_answer;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_quest_answer >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_quest_answer
  (
   p_validate                      in     boolean  default false
  ,p_questionnaire_answer_id       in     number
  ) is
  --
  -- Declare cursors and local variables
  --

  Cursor c_hr_quest_answer_vals is

     SELECT quest_answer_val_id, object_version_number from HR_QUEST_ANSWER_VALUES where questionnaire_answer_id = p_questionnaire_answer_id;



  l_proc                varchar2(72) := g_package||'delete_quest_answer';

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_quest_answer;
  --
  -- Remember IN OUT parameter IN values
  --

  --
  -- Truncate the time portion from all IN date parameters
  --

  --
  -- Call Before Process User Hook
  --
  begin
    hr_quest_answer_bk3.delete_quest_answer_b
      (
        p_questionnaire_answer_id        => p_questionnaire_answer_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_quest_answer'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --



  --
  -- Process Logic
  --
  -- Deleting in the child table (HR_QUEST_ANSWER_VALUES)

   FOR hr_quest_answer_vals_rec in c_hr_quest_answer_vals LOOP

                hr_quest_ans_val_api.delete_quest_answer_val
          	(
          	 p_validate => false -- as per documentaion always should pass false when one BP calls another BP
          	,p_quest_answer_val_id  => hr_quest_answer_vals_rec.quest_answer_val_id
          	,p_object_version_number => hr_quest_answer_vals_rec.object_version_number
          	);

   END LOOP;

   --

   hr_qsa_del.del
   (
          p_questionnaire_answer_id       => p_questionnaire_answer_id
   );
  --
  -- Call After Process User Hook
  --
  begin
    hr_quest_answer_bk3.delete_quest_answer_a
      (
        p_questionnaire_answer_id        => p_questionnaire_answer_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_quest_answer'
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
  -- Set all IN OUT and OUT parameters with out values
  --


  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_quest_answer;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --

    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to delete_quest_answer;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --

    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_quest_answer;
--

end hr_quest_answer_api;

/
