--------------------------------------------------------
--  DDL for Package Body HR_QUEST_ANS_VAL_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_QUEST_ANS_VAL_API" as
/* $Header: hrqsvapi.pkb 120.0 2005/05/31 02:30:21 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_quest_ans_val_api.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< insert_quest_answer_val >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure insert_quest_answer_val
  ( p_validate                       in     boolean  default false
   ,p_questionnaire_answer_id        in     number
   ,p_field_id                       in     number
   ,p_value                          in     varchar2 default null
   ,p_quest_answer_val_id               out nocopy number
   ,p_object_version_number             out nocopy number
  )
  is
  --
  -- Declare cursors and local variables
  --
  -- l_effective_date      date;
  l_proc                varchar2(72) := g_package||'insert_quest_answer_val';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint insert_quest_answer_val;
  --
  -- Remember IN OUT parameter IN values
  --
  --
  -- Truncate the time portion from all IN date parameters
  --
  -- l_effective_date := trunc(p_effective_date);

  --
  -- Call Before Process User Hook
  --
  begin

    hr_quest_ans_val_bk1.insert_quest_answer_val_b
      (
       p_questionnaire_answer_id =>  p_questionnaire_answer_id
      ,p_field_id                =>  p_field_id
      ,p_value                   =>  p_value
      );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'insert_quest_answer_val'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --



  --
  -- Process Logic
  --

     hr_qsv_ins.ins
     (
         p_questionnaire_answer_id =>  p_questionnaire_answer_id
        ,p_field_id                =>  p_field_id
        ,p_value                   =>  p_value
        ,p_quest_answer_val_id     =>  p_quest_answer_val_id
        ,p_object_version_number   =>  p_object_version_number
      );


  --
  -- Call After Process User Hook
  --
  begin
    hr_quest_ans_val_bk1.insert_quest_answer_val_a
     (
          p_questionnaire_answer_id =>  p_questionnaire_answer_id
         ,p_field_id                =>  p_field_id
         ,p_value                   =>  p_value
         ,p_quest_answer_val_id     =>  p_quest_answer_val_id
         ,p_object_version_number   =>  p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'insert_quest_answer_val'
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
    rollback to insert_quest_answer_val;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := null;
    p_quest_answer_val_id    := null;

    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to insert_quest_answer_val;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_object_version_number  := null;
    p_quest_answer_val_id    := null;

    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end insert_quest_answer_val;
--

--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_quest_answer_val >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_quest_answer_val
  ( p_validate                     in     boolean  default false
   ,p_quest_answer_val_id          in     number
   ,p_object_version_number        in out nocopy number
   ,p_value                        in     varchar2  default hr_api.g_varchar2
  )
  is
  --
  -- Declare cursors and local variables
  --
  l_object_version_number number;
  l_proc                varchar2(72) := g_package||'update_quest_answer_val';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_quest_answer_val;
  --
  -- Remember IN OUT parameter IN values
  --

  --
  -- Truncate the time portion from all IN date parameters
  --
  -- l_object_version_number:=p_object_version_number;

  --
  -- Call Before Process User Hook
  --
  begin
    hr_quest_ans_val_bk2.update_quest_answer_val_b
      (
          p_quest_answer_val_id      =>  p_quest_answer_val_id
         ,p_object_version_number    =>  p_object_version_number
         ,p_value                    =>  p_value
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_quest_answer_val'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --

  --
  -- Process Logic
  --
  hr_qsv_upd.upd
  (
            p_quest_answer_val_id       =>  p_quest_answer_val_id
           ,p_object_version_number     =>  p_object_version_number
           ,p_value                     =>  p_value

  );

  --
  -- Call After Process User Hook
  --
  begin
    hr_quest_ans_val_bk2.update_quest_answer_val_a
      (
          p_quest_answer_val_id      =>   p_quest_answer_val_id
         ,p_object_version_number    =>   p_object_version_number
         ,p_value                    =>   p_value
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_quest_answer_val'
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
    rollback to update_quest_answer_val;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    p_object_version_number:=l_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_quest_answer_val;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_object_version_number:=l_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_quest_answer_val;



--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_quest_answer_val >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_quest_answer_val
  (
    p_validate                     	   in     boolean  default false
   ,p_quest_answer_val_id                  in     number
   ,p_object_version_number                in     number
  )
  is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'delete_quest_answer_val';

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_quest_answer_val;
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
    hr_quest_ans_val_bk3.delete_quest_answer_val_b
      (
          p_quest_answer_val_id     =>  p_quest_answer_val_id
         ,p_object_version_number   =>  p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_quest_answer_val'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --

  --
  -- Process Logic
  --
  hr_qsv_del.del
  (
   	    p_quest_answer_val_id     =>  p_quest_answer_val_id
           ,p_object_version_number   =>  p_object_version_number

  );

  --
  -- Call After Process User Hook
  --
  begin
    hr_quest_ans_val_bk3.delete_quest_answer_val_a
      (   p_quest_answer_val_id     =>  p_quest_answer_val_id
         ,p_object_version_number   =>  p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_quest_answer_val'
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
    rollback to delete_quest_answer_val;
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
    rollback to delete_quest_answer_val;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_quest_answer_val;

end hr_quest_ans_val_api;

/
