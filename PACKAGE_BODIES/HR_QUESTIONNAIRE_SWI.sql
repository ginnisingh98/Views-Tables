--------------------------------------------------------
--  DDL for Package Body HR_QUESTIONNAIRE_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_QUESTIONNAIRE_SWI" AS
/* $Header: hrqstswi.pkb 120.1 2005/09/09 02:12:16 pveerepa noship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'hr_questionnaire_swi.';
--
--
Procedure delete_questionnaire_fields
  (
	p_questionnaire_template_id in number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_questionnaire_recs >----------------------|
-- ----------------------------------------------------------------------------
/*
PROCEDURE update_questionnaire_recs(p_effective_date IN DATE
				   ,p_quest_tbl IN OUT NOCOPY HR_QUEST_TABLE
			           ,p_error_message OUT NOCOPY LONG
				   ,p_status OUT NOCOPY VARCHAR2) IS
BEGIN
	FOR I in 1 .. p_quest_tbl.count LOOP
            IF (not p_quest_tbl(I).questionnaire_template_id = -1) THEN
		BEGIN
			hr_qsn_upd.upd(p_quest_tbl(I).questionnaire_template_id
				      ,p_quest_tbl(I).available_flag
				      ,p_quest_tbl(I).object_version_number
				      ,p_effective_date);
			EXCEPTION WHEN OTHERS THEN
				p_error_message := SQLERRM||SQLCODE;
				p_status := 'E';
		END;
            END IF;
	END LOOP;
END update_questionnaire_recs;
*/

-- ----------------------------------------------------------------------------
-- |-----------------------< create_questionnaire >---------------------------|
-- ----------------------------------------------------------------------------

Procedure create_questionnaire
  (p_questionnaire_template_id in number
  ,p_name                      in varchar2
  ,p_text                      in CLOB
  ,p_available_flag            in varchar2
  ,p_business_group_id         in number
  ,p_object_version_number     out nocopy number
  ,p_effective_date            in date   default hr_api.g_date
  ,p_validate                  in number default hr_api.g_false_num
  ,p_return_status             out nocopy varchar2) is

  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_questionnaire_template_id        number;
  l_proc    varchar2(72) := g_package ||'create_questionnaire';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_questionnaire_swi;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  --
  -- Convert constant values to their corresponding boolean value
  --
  l_validate :=
    hr_api.constant_to_boolean
      (p_constant_value => p_validate);
  --
  -- Register Surrogate ID or user key values
  --
  hr_qsn_ins.set_base_key_value
    (p_questionnaire_template_id => p_questionnaire_template_id
    );
  --
  -- Call API
  --
  hr_questionnaire_api.create_questionnaire
  (p_questionnaire_template_id    => l_questionnaire_template_id
  ,p_name                         => p_name
  ,p_text                         => p_text
  ,p_available_flag               => p_available_flag
  ,p_business_group_id            => p_business_group_id
  ,p_object_version_number        => p_object_version_number
  ,p_effective_date               => p_effective_date);
  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
  --
  -- Convert API non-warning boolean parameter values
  --
  --
  -- Derive the API return status value based on whether
  -- messages of any type exist in the Multiple Message List.
  -- Also disable Multiple Message Detection.
  --
  If l_validate = TRUE Then
	rollback to create_questionnaire_swi;
  End If;
  --
  p_return_status := hr_multi_message.get_return_status_disable;
  hr_utility.set_location(' Leaving:' || l_proc,20);
  --
exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to create_questionnaire_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number        := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc, 30);
  when others then
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
    rollback to create_questionnaire_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_object_version_number        := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end create_questionnaire;

-- ----------------------------------------------------------------------------
-- |-----------------------< update_questionnaire >---------------------------|
-- ----------------------------------------------------------------------------

Procedure update_questionnaire
  (p_questionnaire_template_id in number
  ,p_object_version_number     in out nocopy number
  ,p_text		       in CLOB
  ,p_available_flag            in varchar2 default hr_api.g_varchar2
  ,p_business_group_id         in number   default hr_api.g_number
  ,p_effective_date            in date     default hr_api.g_date
  ,p_validate                  in number   default hr_api.g_false_num
  ,p_return_status             out nocopy  varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  l_object_version_number         number;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'update_questionnaire';

  l_text    CLOB;
  l_business_group_id	hr_questionnaires.business_group_id%TYPE;

  CURSOR C_Sel1 IS
	  SELECT text, business_group_id
	  FROM  HR_QUESTIONNAIRES
	  WHERE questionnaire_template_id = p_questionnaire_template_id;

Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_questionnaire_swi;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  l_object_version_number         := p_object_version_number;
  --
  -- Convert constant values to their corresponding boolean value
  --
  l_validate :=
    hr_api.constant_to_boolean
      (p_constant_value => p_validate);
  --
  -- Register Surrogate ID or user key values
  --
  --
  -- Call API
  -- Before updating the Text, save Original Text in Local Variable.
  -- OPEN C_Sel1;
  -- FETCH C_Sel1 into l_text, l_business_group_id;
  --
  hr_questionnaire_api.update_questionnaire
   (p_questionnaire_template_id => p_questionnaire_template_id
   ,p_text			=> p_text
   ,p_available_flag		=> p_available_flag
   ,p_business_group_id		=> p_business_group_id
   ,p_object_version_number	=> p_object_version_number
   ,p_effective_date		=> p_effective_date
   );
  --
  -- Check if the Text is updated, delete all fields.
  -- From Java Layer the Text value will Not be passed
  -- in case the Text is not updated.
  IF NOT (p_text = hr_api.g_varchar2) THEN
      delete_questionnaire_fields  (
		p_questionnaire_template_id => p_questionnaire_template_id
      );
  END IF;
  -- CLOSE C_Sel1;

  If l_validate = TRUE Then
	rollback to update_questionnaire_swi;
  End If;
  --
  p_return_status := hr_multi_message.get_return_status_disable;
  hr_utility.set_location(' Leaving:' || l_proc,20);
  --
exception
  when hr_multi_message.error_message_exist then
    --
    rollback to update_questionnaire_swi;
    --
    --
    p_object_version_number        := l_object_version_number;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc, 30);

  when others then
    --
    rollback to update_questionnaire_swi;

    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    p_object_version_number        := l_object_version_number;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);

end update_questionnaire;

--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_questionnaire >---------------------------|
-- ----------------------------------------------------------------------------

Procedure delete_questionnaire
  (p_questionnaire_template_id in number
  ,p_object_version_number     in number
  ,p_validate                  in number default hr_api.g_false_num
  ,p_return_status             out nocopy varchar2
  ) is

  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'delete_questionnaire';

Begin

  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_questionnaire_swi;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  --
  -- Convert constant values to their corresponding boolean value
  --
  l_validate :=
    hr_api.constant_to_boolean
      (p_constant_value => p_validate);
  --

  -- Register Surrogate ID or user key values
  --
  --
  -- Call API
  --

  --delete_questionnaire_fields
  --  (
  --     p_questionnaire_template_id => p_questionnaire_template_id
  --  );

  	hr_questionnaire_api.delete_questionnaire
  	(
	 p_questionnaire_template_id=>p_questionnaire_template_id
	,p_object_version_number=>p_object_version_number
	,p_validate=>l_validate
  	);

  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
  --
  -- Convert API non-warning boolean parameter values
  --
  --
  -- Derive the API return status value based on whether
  -- messages of any type exist in the Multiple Message List.
  -- Also disable Multiple Message Detection.
  --
  If l_validate = TRUE Then
	rollback to delete_questionnaire_swi;
  End If;
  --
  p_return_status := hr_multi_message.get_return_status_disable;
  hr_utility.set_location(' Leaving:' || l_proc,20);
  --
exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to delete_questionnaire_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc, 30);
  when others then
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
    rollback to delete_questionnaire_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end delete_questionnaire;

Procedure delete_questionnaire_fields
  (
	p_questionnaire_template_id in number
  )
  IS

 Cursor C_Quest_Fields  IS
  select field_id, object_version_number
  from hr_quest_fields
  where questionnaire_template_id = p_questionnaire_template_id;

Begin
  -- Call API
  --
  For I in C_Quest_Fields Loop
   Begin
     hr_qsf_del.del
      (I.field_id
      ,I.object_version_number);
   End;
  End Loop;
  --
end delete_questionnaire_fields;


END HR_QUESTIONNAIRE_SWI;

/
