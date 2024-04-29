--------------------------------------------------------
--  DDL for Package Body HR_QUEST_FIELDS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_QUEST_FIELDS_API" as
/* $Header: hrqsfapi.pkb 120.0 2005/05/31 02:26:58 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_quest_fields_api.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< insert_quest_fields >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure insert_quest_fields
  (   p_validate                       in     boolean  default false
     ,p_effective_date                 in     date
     ,p_questionnaire_template_id      in     number
     ,p_name                           in     varchar2
     ,p_type                           in     varchar2
     ,p_sql_required_flag              in     varchar2
     ,p_html_text                      in     varchar2
     ,p_sql_text                       in     varchar2 default null
     ,p_field_id                          out nocopy number
     ,p_object_version_number             out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_effective_date      date;
  l_proc                varchar2(72) := g_package||'insert_quest_fields';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint insert_quest_fields;
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
     hr_quest_fields_bk1.insert_quest_fields_b
      (
        p_effective_date              		    =>l_effective_date
       ,p_questionnaire_template_id   		    =>p_questionnaire_template_id
       ,p_name                        		    =>p_name
       ,p_type                        		    =>p_type
       ,p_sql_required_flag           		    =>p_sql_required_flag
       ,p_html_text                   		    =>p_html_text
       ,p_sql_text                    		    =>p_sql_text
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'insert_quest_fields'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --



  --
  -- Process Logic
  --
  hr_qsf_ins.ins
  (
 	 p_effective_date              		            => l_effective_date
         ,p_questionnaire_template_id   		    => p_questionnaire_template_id
         ,p_name                        		    => p_name
         ,p_type                        		    => p_type
         ,p_sql_required_flag           		    => p_sql_required_flag
         ,p_html_text                   		    => p_html_text
         ,p_sql_text                    		    => p_sql_text
         ,p_field_id                    		    => p_field_id
         ,p_object_version_number       		    => p_object_version_number
  );

  --
  -- Call After Process User Hook
  --
  begin
      hr_quest_fields_bk1.insert_quest_fields_a
      (
      	      p_effective_date              		    =>l_effective_date
             ,p_questionnaire_template_id   		    =>p_questionnaire_template_id
             ,p_name                        		    =>p_name
             ,p_type                        		    =>p_type
             ,p_sql_required_flag           		    =>p_sql_required_flag
             ,p_html_text                   		    =>p_html_text
             ,p_sql_text                    		    =>p_sql_text
             ,p_field_id                    		    =>p_field_id
             ,p_object_version_number       		    =>p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'insert_quest_fields'
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
    rollback to insert_quest_fields;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_field_id                 := null;
    p_object_version_number    := null;

    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to insert_quest_fields;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_field_id                 := null;
    p_object_version_number    := null;

    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end insert_quest_fields;
--

--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_quest_fields >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_quest_fields
  (p_validate                     in     boolean  default false
  ,p_effective_date               in     date
  ,p_field_id                     in     number
  ,p_object_version_number        in out nocopy number
  ,p_questionnaire_template_id    in     number    default hr_api.g_number
  ,p_name                         in     varchar2  default hr_api.g_varchar2
  ,p_type                         in     varchar2  default hr_api.g_varchar2
  ,p_sql_required_flag            in     varchar2  default hr_api.g_varchar2
  ,p_html_text                    in     varchar2  default hr_api.g_varchar2
  ,p_sql_text                     in     varchar2  default hr_api.g_varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_effective_date      date;
  l_object_version_number number;
  l_proc                varchar2(72) := g_package||'update_quest_fields';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_quest_fields;
  --
  -- Remember IN OUT parameter IN values
  --


  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  l_object_version_number:=p_object_version_number;
  --
  -- Call Before Process User Hook
  --
  begin
     hr_quest_fields_bk2.update_quest_fields_b
      (
       p_effective_date            	    =>    l_effective_date
      ,p_field_id                  	    =>    p_field_id
      ,p_object_version_number     	    =>    p_object_version_number
      ,p_questionnaire_template_id 	    =>    p_questionnaire_template_id
      ,p_name                      	    =>    p_name
      ,p_type                      	    =>    p_type
      ,p_sql_required_flag         	    =>    p_sql_required_flag
      ,p_html_text                 	    =>    p_html_text
      ,p_sql_text                  	    =>    p_sql_text
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_quest_fields'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --


  --
  -- Process Logic
  --
  hr_qsf_upd.upd
  (
       p_effective_date            	    =>    p_effective_date
      ,p_field_id                  	    =>    p_field_id
      ,p_object_version_number     	    =>    p_object_version_number
      ,p_sql_text                  	    =>    p_sql_text
  );

  --
  -- Call After Process User Hook
  --
  begin
      hr_quest_fields_bk2.update_quest_fields_a
      (
       p_effective_date            	    =>    l_effective_date
      ,p_field_id                  	    =>    p_field_id
      ,p_object_version_number     	    =>    p_object_version_number
      ,p_questionnaire_template_id 	    =>    p_questionnaire_template_id
      ,p_name                      	    =>    p_name
      ,p_type                      	    =>    p_type
      ,p_sql_required_flag         	    =>    p_sql_required_flag
      ,p_html_text                 	    =>    p_html_text
      ,p_sql_text                  	    =>    p_sql_text
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_quest_fields'
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
    rollback to update_quest_fields;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number    := l_object_version_number;

    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_quest_fields;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --

    p_object_version_number    := l_object_version_number;

    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_quest_fields;
--

--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_quest_fields >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_quest_fields
  (   p_validate                       in     boolean  default false
     ,p_field_id                       in     number
     ,p_object_version_number          in     number
  ) is
  --
  -- Declare cursors and local variables
  --
  Cursor c_hr_que_ans_vals is

   SELECT quest_answer_val_id, object_version_number from HR_QUEST_ANSWER_VALUES where field_id = p_field_id;


   l_proc                varchar2(72) := g_package||'delete_quest_fields';

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_quest_fields;
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
     hr_quest_fields_bk3.delete_quest_fields_b
      (
          p_field_id                    		    => p_field_id
         ,p_object_version_number       		    => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_quest_fields'
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

    FOR hr_que_ans_vals_rec in c_hr_que_ans_vals LOOP

          hr_quest_ans_val_api.delete_quest_answer_val
            	(
            	 p_validate => false  -- as per documentaion always should pass false when one BP calls another BP
            	,p_quest_answer_val_id  => hr_que_ans_vals_rec.quest_answer_val_id
            	,p_object_version_number => hr_que_ans_vals_rec.object_version_number
            	);

   END LOOP;

  hr_qsf_del.del
  (
 	  p_field_id                    		    => p_field_id
         ,p_object_version_number       		    => p_object_version_number
  );

  --
  -- Call After Process User Hook
  --
  begin
      hr_quest_fields_bk3.delete_quest_fields_a
      (
      	      p_field_id                    		    =>p_field_id
             ,p_object_version_number       		    =>p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name =>  'delete_quest_fields'
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
    rollback to delete_quest_fields;
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
    rollback to delete_quest_fields;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --

    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;

end delete_quest_fields;
--

end hr_quest_fields_api;

/
