--------------------------------------------------------
--  DDL for Package Body IRC_REFERRAL_INFO_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_REFERRAL_INFO_SWI" As
/* $Header: irirfswi.pkb 120.2 2008/04/23 03:41:46 vmummidi noship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'irc_referral_info_swi.';
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_referral_info >-------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_referral_info
  (p_validate                       in       number   default hr_api.g_false_num
  ,p_object_id                   	in 		 number
  ,p_object_type                    in 		 varchar2
  ,p_source_type            		in 		 varchar2 default null
  ,p_source_name            		in 		 varchar2 default null
  ,p_source_criteria1               in 	     varchar2 default null
  ,p_source_value1            	    in 		 varchar2 default null
  ,p_source_criteria2               in 		 varchar2 default null
  ,p_source_value2            	    in 		 varchar2 default null
  ,p_source_criteria3               in 		 varchar2 default null
  ,p_source_value3                  in 		 varchar2 default null
  ,p_source_criteria4               in 		 varchar2 default null
  ,p_source_value4                  in 		 varchar2 default null
  ,p_source_criteria5               in 		 varchar2 default null
  ,p_source_value5                  in 		 varchar2 default null
  ,p_source_person_id               in 		 number   default null
  ,p_candidate_comment              in 		 varchar2 default null
  ,p_employee_comment               in 		 varchar2 default null
  ,p_irf_attribute_category         in 		 varchar2 default null
  ,p_irf_attribute1                 in 		 varchar2 default null
  ,p_irf_attribute2                 in 		 varchar2 default null
  ,p_irf_attribute3                 in 		 varchar2 default null
  ,p_irf_attribute4                 in 		 varchar2 default null
  ,p_irf_attribute5                 in 		 varchar2 default null
  ,p_irf_attribute6                 in 		 varchar2 default null
  ,p_irf_attribute7                 in 		 varchar2 default null
  ,p_irf_attribute8                 in 		 varchar2 default null
  ,p_irf_attribute9                 in 		 varchar2 default null
  ,p_irf_attribute10                in 		 varchar2 default null
  ,p_irf_information_category       in 		 varchar2 default null
  ,p_irf_information1               in 		 varchar2 default null
  ,p_irf_information2               in 		 varchar2 default null
  ,p_irf_information3               in 		 varchar2 default null
  ,p_irf_information4               in 		 varchar2 default null
  ,p_irf_information5               in 		 varchar2 default null
  ,p_irf_information6               in 		 varchar2 default null
  ,p_irf_information7               in 		 varchar2 default null
  ,p_irf_information8               in 		 varchar2 default null
  ,p_irf_information9               in 		 varchar2 default null
  ,p_irf_information10              in 		 varchar2 default null
  ,p_object_created_by              in 		 varchar2 default null
  ,p_referral_info_id               in       number
  ,p_object_version_number          out nocopy number
  ,p_start_date                     out nocopy date
  ,p_end_date                       out nocopy date
  ,p_return_status                  out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_referral_info_id             number;
  l_proc    varchar2(72) := g_package ||'create_referral_info';
  --
  Cursor csr_get_party_id
  is SELECT PARTY_ID FROM PER_ALL_PEOPLE_F
  WHERE PERSON_ID=p_object_id;
  --
  l_party_id number;
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_referral_info_swi;
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
  irc_irf_ins.set_base_key_value
    (p_referral_info_id => p_referral_info_id
    );
  --
  hr_utility.set_location(' p_object_id: '||p_object_id ,11);
  --
  IF P_OBJECT_TYPE='PERSON' THEN
  --
    open csr_get_party_id;
    fetch csr_get_party_id into l_party_id;
    close csr_get_party_id;
  --
  ELSE
  --
    l_party_id := p_object_id;
  --
  END IF;
  --
  -- Call API
  --
  irc_referral_info_api.create_referral_info
    (p_validate                  => l_validate
    ,p_object_id				 =>	l_party_id
    ,p_object_type				 =>	p_object_type
    ,p_source_type				 =>	p_source_type
    ,p_source_name				 =>	p_source_name
    ,p_source_criteria1			 =>	p_source_criteria1
    ,p_source_value1			 =>	p_source_value1
    ,p_source_criteria2			 =>	p_source_criteria2
    ,p_source_value2			 =>	p_source_value2
    ,p_source_criteria3			 =>	p_source_criteria3
    ,p_source_value3			 =>	p_source_value3
    ,p_source_criteria4			 =>	p_source_criteria4
    ,p_source_value4			 =>	p_source_value4
    ,p_source_criteria5			 =>	p_source_criteria5
    ,p_source_value5			 =>	p_source_value5
    ,p_source_person_id			 =>	p_source_person_id
    ,p_candidate_comment		 =>	p_candidate_comment
    ,p_employee_comment			 =>	p_employee_comment
    ,p_irf_attribute_category	 =>	p_irf_attribute_category
    ,p_irf_attribute1			 =>	p_irf_attribute1
    ,p_irf_attribute2			 =>	p_irf_attribute2
    ,p_irf_attribute3			 =>	p_irf_attribute3
    ,p_irf_attribute4			 =>	p_irf_attribute4
    ,p_irf_attribute5			 =>	p_irf_attribute5
    ,p_irf_attribute6			 =>	p_irf_attribute6
    ,p_irf_attribute7			 =>	p_irf_attribute7
    ,p_irf_attribute8			 =>	p_irf_attribute8
    ,p_irf_attribute9			 =>	p_irf_attribute9
    ,p_irf_attribute10			 =>	p_irf_attribute10
    ,p_irf_information_category	 =>	p_irf_information_category
    ,p_irf_information1			 =>	p_irf_information1
    ,p_irf_information2			 =>	p_irf_information2
    ,p_irf_information3			 =>	p_irf_information3
    ,p_irf_information4			 =>	p_irf_information4
    ,p_irf_information5			 =>	p_irf_information5
    ,p_irf_information6			 =>	p_irf_information6
    ,p_irf_information7			 =>	p_irf_information7
    ,p_irf_information8			 =>	p_irf_information8
    ,p_irf_information9			 =>	p_irf_information9
    ,p_irf_information10		 =>	p_irf_information10
    ,p_object_created_by		 =>	p_object_created_by
    ,p_referral_info_id          => l_referral_info_id
    ,p_object_version_number     => p_object_version_number
    ,p_start_date                => p_start_date
    ,p_end_date                  => p_end_date
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
    rollback to create_referral_info_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number    := null;
    p_start_date               := null;
    p_end_date                 := null;
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
    rollback to create_referral_info_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_object_version_number    := null;
    p_start_date               := null;
    p_end_date                 := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end create_referral_info;
-- ----------------------------------------------------------------------------
-- |-------------------------< update_referral_info >--------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_referral_info
  (p_validate                       in       number   default hr_api.g_false_num
  ,p_referral_info_id               in       number
  ,p_source_type            		in 		 varchar2 default hr_api.g_varchar2
  ,p_source_name            		in 		 varchar2 default hr_api.g_varchar2
  ,p_source_criteria1               in 	     varchar2 default hr_api.g_varchar2
  ,p_source_value1            	    in 		 varchar2 default hr_api.g_varchar2
  ,p_source_criteria2               in 		 varchar2 default hr_api.g_varchar2
  ,p_source_value2            	    in 		 varchar2 default hr_api.g_varchar2
  ,p_source_criteria3               in 		 varchar2 default hr_api.g_varchar2
  ,p_source_value3                  in 		 varchar2 default hr_api.g_varchar2
  ,p_source_criteria4               in 		 varchar2 default hr_api.g_varchar2
  ,p_source_value4                  in 		 varchar2 default hr_api.g_varchar2
  ,p_source_criteria5               in 		 varchar2 default hr_api.g_varchar2
  ,p_source_value5                  in 		 varchar2 default hr_api.g_varchar2
  ,p_source_person_id               in 		 number   default hr_api.g_number
  ,p_candidate_comment              in 		 varchar2 default hr_api.g_varchar2
  ,p_employee_comment               in 		 varchar2 default hr_api.g_varchar2
  ,p_irf_attribute_category         in 		 varchar2 default hr_api.g_varchar2
  ,p_irf_attribute1                 in 		 varchar2 default hr_api.g_varchar2
  ,p_irf_attribute2                 in 		 varchar2 default hr_api.g_varchar2
  ,p_irf_attribute3                 in 		 varchar2 default hr_api.g_varchar2
  ,p_irf_attribute4                 in 		 varchar2 default hr_api.g_varchar2
  ,p_irf_attribute5                 in 		 varchar2 default hr_api.g_varchar2
  ,p_irf_attribute6                 in 		 varchar2 default hr_api.g_varchar2
  ,p_irf_attribute7                 in 		 varchar2 default hr_api.g_varchar2
  ,p_irf_attribute8                 in 		 varchar2 default hr_api.g_varchar2
  ,p_irf_attribute9                 in 		 varchar2 default hr_api.g_varchar2
  ,p_irf_attribute10                in 		 varchar2 default hr_api.g_varchar2
  ,p_irf_information_category       in 		 varchar2 default hr_api.g_varchar2
  ,p_irf_information1               in 		 varchar2 default hr_api.g_varchar2
  ,p_irf_information2               in 		 varchar2 default hr_api.g_varchar2
  ,p_irf_information3               in 		 varchar2 default hr_api.g_varchar2
  ,p_irf_information4               in 		 varchar2 default hr_api.g_varchar2
  ,p_irf_information5               in 		 varchar2 default hr_api.g_varchar2
  ,p_irf_information6               in 		 varchar2 default hr_api.g_varchar2
  ,p_irf_information7               in 		 varchar2 default hr_api.g_varchar2
  ,p_irf_information8               in 		 varchar2 default hr_api.g_varchar2
  ,p_irf_information9               in 		 varchar2 default hr_api.g_varchar2
  ,p_irf_information10              in 		 varchar2 default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_start_date                     out nocopy date
  ,p_end_date                       out nocopy date
  ,p_return_status                  out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  l_object_version_number         number;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'update_referral_info';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_referral_info_swi;
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
  --
  irc_referral_info_api.update_referral_info
    (p_validate                  => l_validate
    ,p_referral_info_id          => p_referral_info_id
    ,p_source_type				 =>	p_source_type
    ,p_source_name				 =>	p_source_name
    ,p_source_criteria1			 =>	p_source_criteria1
    ,p_source_value1			 =>	p_source_value1
    ,p_source_criteria2			 =>	p_source_criteria2
    ,p_source_value2			 =>	p_source_value2
    ,p_source_criteria3			 =>	p_source_criteria3
    ,p_source_value3			 =>	p_source_value3
    ,p_source_criteria4			 =>	p_source_criteria4
    ,p_source_value4			 =>	p_source_value4
    ,p_source_criteria5			 =>	p_source_criteria5
    ,p_source_value5			 =>	p_source_value5
    ,p_source_person_id			 =>	p_source_person_id
    ,p_candidate_comment		 =>	p_candidate_comment
    ,p_employee_comment			 =>	p_employee_comment
    ,p_irf_attribute_category	 =>	p_irf_attribute_category
    ,p_irf_attribute1			 =>	p_irf_attribute1
    ,p_irf_attribute2			 =>	p_irf_attribute2
    ,p_irf_attribute3			 =>	p_irf_attribute3
    ,p_irf_attribute4			 =>	p_irf_attribute4
    ,p_irf_attribute5			 =>	p_irf_attribute5
    ,p_irf_attribute6			 =>	p_irf_attribute6
    ,p_irf_attribute7			 =>	p_irf_attribute7
    ,p_irf_attribute8			 =>	p_irf_attribute8
    ,p_irf_attribute9			 =>	p_irf_attribute9
    ,p_irf_attribute10			 =>	p_irf_attribute10
    ,p_irf_information_category	 =>	p_irf_information_category
    ,p_irf_information1			 =>	p_irf_information1
    ,p_irf_information2			 =>	p_irf_information2
    ,p_irf_information3			 =>	p_irf_information3
    ,p_irf_information4			 =>	p_irf_information4
    ,p_irf_information5			 =>	p_irf_information5
    ,p_irf_information6			 =>	p_irf_information6
    ,p_irf_information7			 =>	p_irf_information7
    ,p_irf_information8			 =>	p_irf_information8
    ,p_irf_information9			 =>	p_irf_information9
    ,p_irf_information10		 =>	p_irf_information10
    ,p_object_version_number     => p_object_version_number
    ,p_start_date                => p_start_date
    ,p_end_date                  => p_end_date
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
    rollback to update_referral_info_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_start_date                   := null;
    p_end_date                     := null;
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
    rollback to update_referral_info_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_start_date                   := null;
    p_end_date                     := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end update_referral_info;
---
end IRC_REFERRAL_INFO_SWI;

/
