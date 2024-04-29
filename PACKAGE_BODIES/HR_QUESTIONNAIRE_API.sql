--------------------------------------------------------
--  DDL for Package Body HR_QUESTIONNAIRE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_QUESTIONNAIRE_API" as
/* $Header: hrqsnapi.pkb 120.1 2005/09/09 02:11:57 pveerepa noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'hr_questionnaire_api.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_questionnaire >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_questionnaire
  (
   p_validate              	    in     boolean   default false
  ,p_name                           in     varchar2
  ,p_available_flag                 in     varchar2
  ,p_business_group_id              in     number
  ,p_text                           in     CLOB
  ,p_effective_date                 in     date
  ,p_questionnaire_template_id         out nocopy number
  ,p_object_version_number             out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_effective_date        date;
  l_proc                  varchar2(72) := g_package||'create_questionnaire';
  l_object_version_number number;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_questionnaire;
  --
  -- Remember IN OUT parameter IN values
  --
    l_object_version_number:=p_object_version_number;

  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);

  --
  -- Call Before Process User Hook
  --
  begin
      hr_questionnaire_bk1.create_questionnaire_b
      (
      		p_effective_date                 => l_effective_date
 	       ,p_name                           => p_name
  	       ,p_available_flag                 => p_available_flag
  	       ,p_business_group_id              => p_business_group_id
  	       ,p_text                           => NULL
      );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_questionnaire'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --



  --
  -- Process Logic
  --

   hr_qsn_ins.ins
       (
		p_effective_date                 => p_effective_date
 	       ,p_name                           => p_name
  	       ,p_available_flag                 => p_available_flag
  	       ,p_business_group_id              => p_business_group_id
  	       ,p_text                           => p_text
               ,p_questionnaire_template_id      => p_questionnaire_template_id
               ,p_object_version_number          => p_object_version_number
      );
  --
  -- Call After Process User Hook
  --
  begin
       hr_questionnaire_bk1.create_questionnaire_a
      (
                p_effective_date                 => l_effective_date
 	       ,p_name                           => p_name
  	       ,p_available_flag                 => p_available_flag
  	       ,p_business_group_id              => p_business_group_id
  	       ,p_text                           => NULL
               ,p_questionnaire_template_id      => p_questionnaire_template_id
               ,p_object_version_number          => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_questionnaire'
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
    rollback to create_questionnaire;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number     := null;
    p_questionnaire_template_id :=null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_questionnaire;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_object_version_number               := null;
    p_questionnaire_template_id           := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_questionnaire;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_questionnaire >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_questionnaire
  (
   p_validate              	  in     boolean   default false
  ,p_questionnaire_template_id    in     number
  ,p_object_version_number        in out nocopy number
  ,p_effective_date               in     date
  ,p_name                         in     varchar2  default hr_api.g_varchar2
  ,p_available_flag               in     varchar2  default hr_api.g_varchar2
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_text                         in     CLOB
  ) is
  --
  -- Declare cursors and local variables
  --
  l_effective_date      date;
  l_object_version_number number;
  l_proc                varchar2(72) := g_package||'update_questionnaire';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_questionnaire;
  --
  -- Remember IN OUT parameter IN values
  --
     l_object_version_number:=p_object_version_number;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);

  --
  -- Call Before Process User Hook
  --
  begin
      hr_questionnaire_bk2.update_questionnaire_b
      (      p_effective_date               => l_effective_date
	    ,p_questionnaire_template_id    => p_questionnaire_template_id
	    ,p_object_version_number        => p_object_version_number
	    ,p_name                         => p_name
	    ,p_available_flag               => p_available_flag
	    ,p_business_group_id            => p_business_group_id
  	    ,p_text                         => NULL
      );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_questionnaire'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --



  --
  -- Process Logic
  --

   hr_qsn_upd.upd
       (
             p_effective_date               => p_effective_date
	    ,p_questionnaire_template_id    => p_questionnaire_template_id
	    ,p_object_version_number        => p_object_version_number
	    ,p_available_flag               => p_available_flag
	    ,p_business_group_id            => p_business_group_id
  	    ,p_text                         => p_text
      );
  --
  -- Call After Process User Hook
  --
  begin

      hr_questionnaire_bk2.update_questionnaire_a
      (      p_effective_date               => l_effective_date
	    ,p_questionnaire_template_id    => p_questionnaire_template_id
	    ,p_object_version_number        => p_object_version_number
	    ,p_name                         => p_name
	    ,p_available_flag               => p_available_flag
	    ,p_business_group_id            => p_business_group_id
  	    ,p_text                         => NULL
      );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_questionnaire'
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
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_questionnaire;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number:=l_object_version_number;

    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_questionnaire;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_object_version_number:=l_object_version_number;

    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_questionnaire;

--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_questionnaire >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_questionnaire
 (
   p_validate                             in     boolean   default false
  ,p_questionnaire_template_id            in     number
  ,p_object_version_number                in     number
  ) is
  --
  -- Declare cursors and local variables
  --

  Cursor c_hr_que_ans is

     SELECT questionnaire_answer_id  /*, object_version_number */ from HR_QUEST_ANSWERS where questionnaire_template_id = p_questionnaire_template_id;

   Cursor c_hr_que_flds is

     SELECT field_id, object_version_number from HR_QUEST_FIELDS where questionnaire_template_id = p_questionnaire_template_id;

  l_effective_date      date;
  l_proc                varchar2(72) := g_package||'delete_questionnaire';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_questionnaire;
  --
  -- Remember IN OUT parameter IN values

  --
  -- Truncate the time portion from all IN date parameters

  --
  -- Call Before Process User Hook
  --
  begin
    hr_questionnaire_bk3.delete_questionnaire_b
      (
           p_questionnaire_template_id           => p_questionnaire_template_id
  	  ,p_object_version_number               => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_questionnaire'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --



  --
  -- Process Logic

  -- Deleting Matchig Rows in the child table (HR_QUEST_ANSWERS)

      FOR hr_que_ans_rec in c_hr_que_ans LOOP

           hr_quest_answer_api.delete_quest_answer
             	(
             	 p_validate => false -- as per documentaion always should pass false when one BP calls another BP
             	,p_questionnaire_answer_id  => hr_que_ans_rec.questionnaire_answer_id
             	--,p_object_version_number    => hr_que_ans_rec.object_version_number
             	);

      END LOOP;


   -- Deleting Matchig Rows in the child table (HR_QUEST_FIELDS)

         FOR hr_que_flds_rec in c_hr_que_flds LOOP

               hr_quest_fields_api.delete_quest_fields
		(
		 p_validate => false -- as per documentaion always should pass false when one BP calls another BP
		,p_field_id  => hr_que_flds_rec.field_id
		,p_object_version_number    => hr_que_flds_rec.object_version_number
		);

         END LOOP;

   --Deleting the Row.

     hr_qsn_del.del
      (
           p_questionnaire_template_id           => p_questionnaire_template_id
	  ,p_object_version_number               => p_object_version_number
      );
  --
  -- Call After Process User Hook
  --
  begin

     hr_questionnaire_bk3.delete_questionnaire_a
     (
           p_questionnaire_template_id           => p_questionnaire_template_id
  	  ,p_object_version_number               => p_object_version_number
     );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_questionnaire'
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
    rollback to delete_questionnaire;
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
    rollback to delete_questionnaire;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --

    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_questionnaire;

end hr_questionnaire_api;

/
