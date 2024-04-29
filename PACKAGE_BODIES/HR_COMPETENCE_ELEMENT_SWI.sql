--------------------------------------------------------
--  DDL for Package Body HR_COMPETENCE_ELEMENT_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_COMPETENCE_ELEMENT_SWI" As
/* $Header: hrcelswi.pkb 120.4.12010000.4 2009/07/21 07:51:01 rvagvala ship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'hr_competence_element_swi.';
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_competence_element >----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_competence_element
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_competence_element_id        in     number
  ,p_object_version_number           out nocopy number
  ,p_type                         in     varchar2
  ,p_business_group_id            in     number    default null
  ,p_enterprise_id                in     number    default null
  ,p_competence_id                in     number    default null
  ,p_proficiency_level_id         in     number    default null
  ,p_high_proficiency_level_id    in     number    default null
  ,p_weighting_level_id           in     number    default null
  ,p_rating_level_id              in     number    default null
  ,p_person_id                    in     number    default null
  ,p_job_id                       in     number    default null
  ,p_valid_grade_id               in     number    default null
  ,p_position_id                  in     number    default null
  ,p_organization_id              in     number    default null
  ,p_parent_competence_element_id in     number    default null
  ,p_activity_version_id          in     number    default null
  ,p_assessment_id                in     number    default null
  ,p_assessment_type_id           in     number    default null
  ,p_mandatory                    in     varchar2  default null
  ,p_effective_date_from          in     date      default null
  ,p_effective_date_to            in     date      default null
  ,p_group_competence_type        in     varchar2  default null
  ,p_competence_type              in     varchar2  default null
  ,p_normal_elapse_duration       in     number    default null
  ,p_normal_elapse_duration_unit  in     varchar2  default null
  ,p_sequence_number              in     number    default null
  ,p_source_of_proficiency_level  in     varchar2  default null
  ,p_line_score                   in     number    default null
  ,p_certification_date           in     date      default null
  ,p_certification_method         in     varchar2  default null
  ,p_next_certification_date      in     date      default null
  ,p_comments                     in     varchar2  default null
  ,p_attribute_category           in     varchar2  default null
  ,p_attribute1                   in     varchar2  default null
  ,p_attribute2                   in     varchar2  default null
  ,p_attribute3                   in     varchar2  default null
  ,p_attribute4                   in     varchar2  default null
  ,p_attribute5                   in     varchar2  default null
  ,p_attribute6                   in     varchar2  default null
  ,p_attribute7                   in     varchar2  default null
  ,p_attribute8                   in     varchar2  default null
  ,p_attribute9                   in     varchar2  default null
  ,p_attribute10                  in     varchar2  default null
  ,p_attribute11                  in     varchar2  default null
  ,p_attribute12                  in     varchar2  default null
  ,p_attribute13                  in     varchar2  default null
  ,p_attribute14                  in     varchar2  default null
  ,p_attribute15                  in     varchar2  default null
  ,p_attribute16                  in     varchar2  default null
  ,p_attribute17                  in     varchar2  default null
  ,p_attribute18                  in     varchar2  default null
  ,p_attribute19                  in     varchar2  default null
  ,p_attribute20                  in     varchar2  default null
  ,p_effective_date               in     date
  ,p_object_id                    in     number    default null
  ,p_object_name                  in     varchar2  default null
  ,p_party_id                     in     number    default null
  ,p_return_status                   out nocopy varchar2
  ,p_appr_line_score              in    number     default null
  ,p_status                       in     varchar2  default null
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_competence_element_id        number;
  l_proc    varchar2(72) := g_package ||'create_competence_element';

Begin
  hr_utility.set_location(' Entering:' || l_proc,10);

    g_session_id := NULL;
    g_competence_element_id := NULL;
  --
  -- Issue a savepoint
  --
  savepoint create_competence_element_swi;
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
  per_cel_ins.set_base_key_value
    (p_competence_element_id => p_competence_element_id
    );
  --
  -- Call API
  --
  hr_competence_element_api.create_competence_element
    (p_validate                     => l_validate
    ,p_competence_element_id        => l_competence_element_id
    ,p_object_version_number        => p_object_version_number
    ,p_type                         => p_type
    ,p_business_group_id            => p_business_group_id
    ,p_enterprise_id                => p_enterprise_id
    ,p_competence_id                => p_competence_id
    ,p_proficiency_level_id         => p_proficiency_level_id
    ,p_high_proficiency_level_id    => p_high_proficiency_level_id
    ,p_weighting_level_id           => p_weighting_level_id
    ,p_rating_level_id              => p_rating_level_id
    ,p_person_id                    => p_person_id
    ,p_job_id                       => p_job_id
    ,p_valid_grade_id               => p_valid_grade_id
    ,p_position_id                  => p_position_id
    ,p_organization_id              => p_organization_id
    ,p_parent_competence_element_id => p_parent_competence_element_id
    ,p_activity_version_id          => p_activity_version_id
    ,p_assessment_id                => p_assessment_id
    ,p_assessment_type_id           => p_assessment_type_id
    ,p_mandatory                    => p_mandatory
    ,p_effective_date_from          => p_effective_date_from
    ,p_effective_date_to            => p_effective_date_to
    ,p_group_competence_type        => p_group_competence_type
    ,p_competence_type              => p_competence_type
    ,p_normal_elapse_duration       => p_normal_elapse_duration
    ,p_normal_elapse_duration_unit  => p_normal_elapse_duration_unit
    ,p_sequence_number              => p_sequence_number
    ,p_source_of_proficiency_level  => p_source_of_proficiency_level
    ,p_line_score                   => p_line_score
    ,p_certification_date           => p_certification_date
    ,p_certification_method         => p_certification_method
    ,p_next_certification_date      => p_next_certification_date
    ,p_comments                     => p_comments
    ,p_attribute_category           => p_attribute_category
    ,p_attribute1                   => p_attribute1
    ,p_attribute2                   => p_attribute2
    ,p_attribute3                   => p_attribute3
    ,p_attribute4                   => p_attribute4
    ,p_attribute5                   => p_attribute5
    ,p_attribute6                   => p_attribute6
    ,p_attribute7                   => p_attribute7
    ,p_attribute8                   => p_attribute8
    ,p_attribute9                   => p_attribute9
    ,p_attribute10                  => p_attribute10
    ,p_attribute11                  => p_attribute11
    ,p_attribute12                  => p_attribute12
    ,p_attribute13                  => p_attribute13
    ,p_attribute14                  => p_attribute14
    ,p_attribute15                  => p_attribute15
    ,p_attribute16                  => p_attribute16
    ,p_attribute17                  => p_attribute17
    ,p_attribute18                  => p_attribute18
    ,p_attribute19                  => p_attribute19
    ,p_attribute20                  => p_attribute20
    ,p_effective_date               => p_effective_date
    ,p_object_id                    => p_object_id
    ,p_object_name                  => p_object_name
    ,p_party_id                     => p_party_id
    ,p_appr_line_score              => p_appr_line_score
    ,p_status                       => p_status
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
    rollback to create_competence_element_swi;
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
    rollback to create_competence_element_swi;
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
end create_competence_element;
-- ----------------------------------------------------------------------------
-- |---------------------------< copy_competencies >--------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE copy_competencies
  (p_activity_version_from        in     number
  ,p_activity_version_to          in     number
  ,p_competence_type              in     varchar2  default hr_api.g_varchar2
  ,p_validate                     in     number    default hr_api.g_false_num
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'copy_competencies';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint copy_competencies_swi;
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
  hr_competence_element_api.copy_competencies
    (p_activity_version_from        => p_activity_version_from
    ,p_activity_version_to          => p_activity_version_to
    ,p_competence_type              => p_competence_type
    ,p_validate                     => l_validate
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
    rollback to copy_competencies_swi;
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
    rollback to copy_competencies_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end copy_competencies;
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_competence_element >----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_competence_element
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_competence_element_id        in     number
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'delete_competence_element';
  l_object_version_number per_competence_elements.object_version_number%TYPE;

  cursor get_object_version_number(p_competence_element_id per_competence_elements.competence_element_id%TYPE) is
  select object_version_number
    from per_competence_elements
   where competence_element_id = p_competence_element_id;
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);

    g_session_id := NULL;
    g_competence_element_id := NULL;
  --
  -- Issue a savepoint
  --
  savepoint delete_competence_element_swi;
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
  l_object_version_number := p_object_version_number;
  if(p_object_version_number is null or p_object_version_number < 0) then
    open get_object_version_number(p_competence_element_id);
    fetch get_object_version_number into l_object_version_number;
    close get_object_version_number;
  end if;
  --
  hr_competence_element_api.delete_competence_element
    (p_validate                     => l_validate
    ,p_competence_element_id        => p_competence_element_id
    ,p_object_version_number        => l_object_version_number
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
    rollback to delete_competence_element_swi;
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
    rollback to delete_competence_element_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end delete_competence_element;
-- ----------------------------------------------------------------------------
-- |---------------------< maintain_student_comp_element >--------------------|
-- ----------------------------------------------------------------------------
PROCEDURE maintain_student_comp_element
  (p_person_id                    in     number
  ,p_competence_id                in     number
  ,p_proficiency_level_id         in     number
  ,p_business_group_id            in     number
  ,p_effective_date_from          in     date
  ,p_effective_date_to            in     date
  ,p_certification_date           in     date
  ,p_certification_method         in     varchar2
  ,p_next_certification_date      in     date
  ,p_source_of_proficiency_level  in     varchar2
  ,p_comments                     in     varchar2
  ,p_effective_date               in     date
  ,p_validate                     in     number    default hr_api.g_false_num
  ,p_competence_created              out nocopy number
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'maintain_student_comp_element';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint maintain_student_comp_ele_swi;
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
  hr_competence_element_api.maintain_student_comp_element
    (p_person_id                    => p_person_id
    ,p_competence_id                => p_competence_id
    ,p_proficiency_level_id         => p_proficiency_level_id
    ,p_business_group_id            => p_business_group_id
    ,p_effective_date_from          => p_effective_date_from
    ,p_effective_date_to            => p_effective_date_to
    ,p_certification_date           => p_certification_date
    ,p_certification_method         => p_certification_method
    ,p_next_certification_date      => p_next_certification_date
    ,p_source_of_proficiency_level  => p_source_of_proficiency_level
    ,p_comments                     => p_comments
    ,p_effective_date               => p_effective_date
    ,p_validate                     => l_validate
    ,p_competence_created           => p_competence_created
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
    rollback to maintain_student_comp_ele_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_competence_created           := null;
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
    rollback to maintain_student_comp_ele_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_competence_created           := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end maintain_student_comp_element;

-- ----------------------------------------------------------------------------
-- |-----------------------< get_non_gmisc_value >----------------------|
-- ----------------------------------------------------------------------------

function get_non_gmisc_value
	(p_old_value in date
    ,p_current_value in date
	) return date is
begin
	if p_current_value = hr_api.g_date then
		return p_old_value;
	else
		return p_current_value;
	end if;
end get_non_gmisc_value;

-- ----------------------------------------------------------------------------
-- |-----------------------< get_non_gmisc_value >----------------------|
-- ----------------------------------------------------------------------------


function get_non_gmisc_value
	(p_old_value in number
    ,p_current_value in number
	) return number is
begin
	if p_current_value = hr_api.g_number then
		return p_old_value;
	else
		return p_current_value;
	end if;
end get_non_gmisc_value;

-- ----------------------------------------------------------------------------
-- |-----------------------< get_non_gmisc_value >----------------------|
-- ----------------------------------------------------------------------------


function get_non_gmisc_value
	(p_old_value in varchar2
    ,p_current_value in varchar2
	) return varchar2 is
begin
	if p_current_value = hr_api.g_varchar2 then
		return p_old_value;
	else
		return p_current_value;
	end if;
end get_non_gmisc_value;



-- ----------------------------------------------------------------------------
-- |-----------------------< update_competence_element >----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_competence_element
  (p_competence_element_id        in     number
  ,p_object_version_number        in out nocopy number
  ,p_competence_id                in     number    default hr_api.g_number
  ,p_proficiency_level_id         in     number    default hr_api.g_number
  ,p_high_proficiency_level_id    in     number    default hr_api.g_number
  ,p_weighting_level_id           in     number    default hr_api.g_number
  ,p_rating_level_id              in     number    default hr_api.g_number
  ,p_mandatory                    in     varchar2  default hr_api.g_varchar2
  ,p_effective_date_from          in     date      default hr_api.g_date
  ,p_effective_date_to            in     date      default hr_api.g_date
  ,p_group_competence_type        in     varchar2  default hr_api.g_varchar2
  ,p_competence_type              in     varchar2  default hr_api.g_varchar2
  ,p_normal_elapse_duration       in     number    default hr_api.g_number
  ,p_normal_elapse_duration_unit  in     varchar2  default hr_api.g_varchar2
  ,p_sequence_number              in     number    default hr_api.g_number
  ,p_source_of_proficiency_level  in     varchar2  default hr_api.g_varchar2
  ,p_line_score                   in     number    default hr_api.g_number
  ,p_certification_date           in     date      default hr_api.g_date
  ,p_certification_method         in     varchar2  default hr_api.g_varchar2
  ,p_next_certification_date      in     date      default hr_api.g_date
  ,p_comments                     in     varchar2  default hr_api.g_varchar2
  ,p_attribute_category           in     varchar2  default hr_api.g_varchar2
  ,p_attribute1                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute2                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute3                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute4                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute5                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute6                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute7                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute8                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute9                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute10                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute11                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute12                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute13                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute14                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute15                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute16                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute17                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute18                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute19                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute20                  in     varchar2  default hr_api.g_varchar2
  ,p_effective_date               in     date
  ,p_validate                     in     number    default hr_api.g_false_num
  ,p_party_id                     in     number
  ,p_return_status                out    nocopy varchar2
  ,p_datetrack_update_mode        in     varchar2  default hr_api.g_correction
  ,p_appr_line_score              in     number    default hr_api.g_number
  ,p_status                       in     varchar2  default null
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  l_object_version_number         number;
  --
  -- Other variables
  l_competence_element_id        number;
  l_effective_date_from          date;
  l_effective_date_to          date;
  l_proc    varchar2(72) := g_package ||'update_competence_element';


Begin
  hr_utility.set_location(' Entering:' || l_proc,10);

    g_session_id := NULL;
    g_competence_element_id := NULL;
  --
  -- Issue a savepoint
  --
  savepoint update_competence_element_swi;
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
  -- look to see if the competence_id has been changed
  --
  per_cel_shd.lck
  (p_competence_element_id        => p_competence_element_id
  ,p_object_version_number        => p_object_version_number
  );
  --
  if p_competence_id<>hr_api.g_number
     and per_cel_shd.g_old_rec.competence_id<>p_competence_id then
    --
    -- the competence has been updated, so delete the old competence element
    -- and insert a new one.
    --
    hr_competence_element_api.delete_competence_element
    (p_validate                     => false
    ,p_competence_element_id        => p_competence_element_id
    ,p_object_version_number        => p_object_version_number
    );
    per_cel_ins.set_base_key_value
    (p_competence_element_id => p_competence_element_id
    );
    --

    hr_competence_element_api.create_competence_element
    (p_validate                     => false
    ,p_competence_element_id        => l_competence_element_id
    ,p_object_version_number        => p_object_version_number
    ,p_type                         => per_cel_shd.g_old_rec.type
    ,p_business_group_id            => per_cel_shd.g_old_rec.business_group_id
    ,p_enterprise_id                => per_cel_shd.g_old_rec.enterprise_id
    ,p_competence_id                => p_competence_id
    ,p_proficiency_level_id         => p_proficiency_level_id
    ,p_high_proficiency_level_id    => p_high_proficiency_level_id
    ,p_weighting_level_id           => p_weighting_level_id
    ,p_rating_level_id              => p_rating_level_id
    ,p_person_id                    => per_cel_shd.g_old_rec.person_id
    ,p_job_id                       => per_cel_shd.g_old_rec.job_id
    ,p_valid_grade_id               => per_cel_shd.g_old_rec.valid_grade_id
    ,p_position_id                  => per_cel_shd.g_old_rec.position_id
    ,p_organization_id              => per_cel_shd.g_old_rec.organization_id
    ,p_parent_competence_element_id => per_cel_shd.g_old_rec.parent_competence_element_id
    ,p_activity_version_id          => per_cel_shd.g_old_rec.activity_version_id
    ,p_assessment_id                => per_cel_shd.g_old_rec.assessment_id
    ,p_assessment_type_id           => per_cel_shd.g_old_rec.assessment_type_id
    ,p_mandatory                    => p_mandatory
    ,p_effective_date_from          => p_effective_date_from
    ,p_effective_date_to            => p_effective_date_to
    ,p_group_competence_type        => p_group_competence_type
    ,p_competence_type              => p_competence_type
    ,p_normal_elapse_duration       => p_normal_elapse_duration
    ,p_normal_elapse_duration_unit  => p_normal_elapse_duration_unit
    ,p_sequence_number              => p_sequence_number
    ,p_source_of_proficiency_level  => p_source_of_proficiency_level
    ,p_line_score                   => p_line_score
    ,p_certification_date           => p_certification_date
    ,p_certification_method         => p_certification_method
    ,p_next_certification_date      => p_next_certification_date
    ,p_comments                     => p_comments
    ,p_attribute_category           => p_attribute_category
    ,p_attribute1                   => p_attribute1
    ,p_attribute2                   => p_attribute2
    ,p_attribute3                   => p_attribute3
    ,p_attribute4                   => p_attribute4
    ,p_attribute5                   => p_attribute5
    ,p_attribute6                   => p_attribute6
    ,p_attribute7                   => p_attribute7
    ,p_attribute8                   => p_attribute8
    ,p_attribute9                   => p_attribute9
    ,p_attribute10                  => p_attribute10
    ,p_attribute11                  => p_attribute11
    ,p_attribute12                  => p_attribute12
    ,p_attribute13                  => p_attribute13
    ,p_attribute14                  => p_attribute14
    ,p_attribute15                  => p_attribute15
    ,p_attribute16                  => p_attribute16
    ,p_attribute17                  => p_attribute17
    ,p_attribute18                  => p_attribute18
    ,p_attribute19                  => p_attribute19
    ,p_attribute20                  => p_attribute20
    ,p_effective_date               => p_effective_date
    ,p_object_id                    => per_cel_shd.g_old_rec.object_id
    ,p_object_name                  => per_cel_shd.g_old_rec.object_name
    ,p_party_id                     => p_party_id
    ,p_appr_line_score              => p_appr_line_score
    ,p_status                       => p_status
    );
  else
    if (nvl(p_datetrack_update_mode, '#')  <> hr_api.g_update) then

    --  the competence has not been changed,
    --  so correct the existing row since datetrackmode is correct

   hr_competence_element_api.update_competence_element
    (p_competence_element_id        => p_competence_element_id
    ,p_object_version_number        => p_object_version_number
    ,p_proficiency_level_id         => p_proficiency_level_id
    ,p_high_proficiency_level_id    => p_high_proficiency_level_id
    ,p_weighting_level_id           => p_weighting_level_id
    ,p_rating_level_id              => p_rating_level_id
    ,p_mandatory                    => p_mandatory
    ,p_effective_date_from          => p_effective_date_from
    ,p_effective_date_to            => p_effective_date_to
    ,p_group_competence_type        => p_group_competence_type
    ,p_competence_type              => p_competence_type
    ,p_normal_elapse_duration       => p_normal_elapse_duration
    ,p_normal_elapse_duration_unit  => p_normal_elapse_duration_unit
    ,p_sequence_number              => p_sequence_number
    ,p_source_of_proficiency_level  => p_source_of_proficiency_level
    ,p_line_score                   => p_line_score
    ,p_certification_date           => p_certification_date
    ,p_certification_method         => p_certification_method
    ,p_next_certification_date      => p_next_certification_date
    ,p_comments                     => p_comments
    ,p_attribute_category           => p_attribute_category
    ,p_attribute1                   => p_attribute1
    ,p_attribute2                   => p_attribute2
    ,p_attribute3                   => p_attribute3
    ,p_attribute4                   => p_attribute4
    ,p_attribute5                   => p_attribute5
    ,p_attribute6                   => p_attribute6
    ,p_attribute7                   => p_attribute7
    ,p_attribute8                   => p_attribute8
    ,p_attribute9                   => p_attribute9
    ,p_attribute10                  => p_attribute10
    ,p_attribute11                  => p_attribute11
    ,p_attribute12                  => p_attribute12
    ,p_attribute13                  => p_attribute13
    ,p_attribute14                  => p_attribute14
    ,p_attribute15                  => p_attribute15
    ,p_attribute16                  => p_attribute16
    ,p_attribute17                  => p_attribute17
    ,p_attribute18                  => p_attribute18
    ,p_attribute19                  => p_attribute19
    ,p_attribute20                  => p_attribute20
    ,p_effective_date               => p_effective_date
    ,p_validate                     => false
    ,p_party_id                     => p_party_id
    ,p_appr_line_score              => p_appr_line_score
    ,p_status                       => p_status
    );
    elsif (p_datetrack_update_mode = hr_api.g_update) then

    --  the competence has not been changed,
    --  so update the existing row since datetrackmode is update
    --  Update implies Maintain history by end-dating the previous row and  inserting a new Row.

     l_effective_date_to:= p_effective_date_from - 1;
     -- End-date the existing row
     hr_competence_element_api.update_competence_element(
      p_competence_element_id        => p_competence_element_id
     ,p_object_version_number        => p_object_version_number
     ,p_effective_date_to            => l_effective_date_to
     ,p_effective_date               => p_effective_date
     );



    --  Add new row

     hr_competence_element_api.create_competence_element
    (p_validate                     => false
    ,p_competence_element_id        => l_competence_element_id
    ,p_object_version_number        => l_object_version_number
    ,p_type                         => per_cel_shd.g_old_rec.type
    ,p_business_group_id            => per_cel_shd.g_old_rec.business_group_id
    ,p_enterprise_id                => per_cel_shd.g_old_rec.enterprise_id
    ,p_competence_id                => get_non_gmisc_value( per_cel_shd.g_old_rec.competence_id,p_competence_id)
    ,p_proficiency_level_id         => get_non_gmisc_value( per_cel_shd.g_old_rec.proficiency_level_id,p_proficiency_level_id)
    ,p_high_proficiency_level_id    => get_non_gmisc_value( per_cel_shd.g_old_rec.high_proficiency_level_id,p_high_proficiency_level_id)
    ,p_weighting_level_id           => get_non_gmisc_value( per_cel_shd.g_old_rec.weighting_level_id,p_weighting_level_id)
    ,p_rating_level_id              => get_non_gmisc_value( per_cel_shd.g_old_rec.rating_level_id,p_rating_level_id)
    ,p_person_id                    => per_cel_shd.g_old_rec.person_id
    ,p_job_id                       => per_cel_shd.g_old_rec.job_id
    ,p_valid_grade_id               => per_cel_shd.g_old_rec.valid_grade_id
    ,p_position_id                  => per_cel_shd.g_old_rec.position_id
    ,p_organization_id              => per_cel_shd.g_old_rec.organization_id
    ,p_parent_competence_element_id => per_cel_shd.g_old_rec.parent_competence_element_id
    ,p_activity_version_id          => per_cel_shd.g_old_rec.activity_version_id
    ,p_assessment_id                => per_cel_shd.g_old_rec.assessment_id
    ,p_assessment_type_id           => per_cel_shd.g_old_rec.assessment_type_id
    ,p_mandatory                    => get_non_gmisc_value( per_cel_shd.g_old_rec.mandatory,p_mandatory)
    ,p_effective_date_from          => get_non_gmisc_value( per_cel_shd.g_old_rec.effective_date_from, p_effective_date_from)
    ,p_effective_date_to            => get_non_gmisc_value( per_cel_shd.g_old_rec.effective_date_to, p_effective_date_to)
    ,p_group_competence_type        => get_non_gmisc_value( per_cel_shd.g_old_rec.group_competence_type,p_group_competence_type)
    ,p_competence_type              => get_non_gmisc_value( per_cel_shd.g_old_rec.competence_type,p_competence_type)
    ,p_normal_elapse_duration       => get_non_gmisc_value( per_cel_shd.g_old_rec.normal_elapse_duration,p_normal_elapse_duration )
    ,p_normal_elapse_duration_unit  => get_non_gmisc_value( per_cel_shd.g_old_rec.normal_elapse_duration_unit,p_normal_elapse_duration_unit)
    ,p_sequence_number              => get_non_gmisc_value( per_cel_shd.g_old_rec.sequence_number,p_sequence_number )
    ,p_source_of_proficiency_level  => get_non_gmisc_value( per_cel_shd.g_old_rec.source_of_proficiency_level, p_source_of_proficiency_level)
    ,p_line_score                   => get_non_gmisc_value( per_cel_shd.g_old_rec.line_score,p_line_score )
    ,p_certification_date           => get_non_gmisc_value( per_cel_shd.g_old_rec.certification_date, p_certification_date)
    ,p_certification_method         => get_non_gmisc_value( per_cel_shd.g_old_rec.certification_method, p_certification_method)
    ,p_next_certification_date      => get_non_gmisc_value( per_cel_shd.g_old_rec.next_certification_date, p_next_certification_date)
    ,p_comments                     => get_non_gmisc_value( per_cel_shd.g_old_rec.comments, p_comments)
    ,p_attribute_category           => get_non_gmisc_value( per_cel_shd.g_old_rec.attribute_category, p_attribute_category)
    ,p_attribute1                   => get_non_gmisc_value( per_cel_shd.g_old_rec.attribute1, p_attribute1)
    ,p_attribute2                   => get_non_gmisc_value( per_cel_shd.g_old_rec.attribute2, p_attribute2)
    ,p_attribute3                   => get_non_gmisc_value( per_cel_shd.g_old_rec.attribute3, p_attribute3)
    ,p_attribute4                   => get_non_gmisc_value( per_cel_shd.g_old_rec.attribute4, p_attribute4)
    ,p_attribute5                   => get_non_gmisc_value( per_cel_shd.g_old_rec.attribute5, p_attribute5)
    ,p_attribute6                   => get_non_gmisc_value( per_cel_shd.g_old_rec.attribute6, p_attribute6)
    ,p_attribute7                   => get_non_gmisc_value( per_cel_shd.g_old_rec.attribute7, p_attribute7)
    ,p_attribute8                   => get_non_gmisc_value( per_cel_shd.g_old_rec.attribute8, p_attribute8)
    ,p_attribute9                   => get_non_gmisc_value( per_cel_shd.g_old_rec.attribute9, p_attribute9)
    ,p_attribute10                  => get_non_gmisc_value( per_cel_shd.g_old_rec.attribute10, p_attribute10)
    ,p_attribute11                  => get_non_gmisc_value( per_cel_shd.g_old_rec.attribute11, p_attribute11)
    ,p_attribute12                  => get_non_gmisc_value( per_cel_shd.g_old_rec.attribute12, p_attribute12)
    ,p_attribute13                  => get_non_gmisc_value( per_cel_shd.g_old_rec.attribute13, p_attribute13)
    ,p_attribute14                  => get_non_gmisc_value( per_cel_shd.g_old_rec.attribute14, p_attribute14)
    ,p_attribute15                  => get_non_gmisc_value( per_cel_shd.g_old_rec.attribute15, p_attribute15)
    ,p_attribute16                  => get_non_gmisc_value( per_cel_shd.g_old_rec.attribute16, p_attribute16)
    ,p_attribute17                  => get_non_gmisc_value( per_cel_shd.g_old_rec.attribute17, p_attribute17)
    ,p_attribute18                  => get_non_gmisc_value( per_cel_shd.g_old_rec.attribute18, p_attribute18)
    ,p_attribute19                  => get_non_gmisc_value( per_cel_shd.g_old_rec.attribute19, p_attribute19)
    ,p_attribute20                  => get_non_gmisc_value( per_cel_shd.g_old_rec.attribute20, p_attribute20)
    ,p_effective_date               => p_effective_date
    ,p_object_id                    => per_cel_shd.g_old_rec.object_id
    ,p_object_name                  => per_cel_shd.g_old_rec.object_name
    ,p_party_id                     => get_non_gmisc_value( per_cel_shd.g_old_rec.party_id, p_party_id)
    ,p_appr_line_score              => get_non_gmisc_value( per_cel_shd.g_old_rec.appr_line_score, p_appr_line_score)
    ,p_status                       => get_non_gmisc_value( per_cel_shd.g_old_rec.status, p_status)
    );
    g_session_id := ICX_SEC.G_SESSION_ID;
    g_competence_element_id := l_competence_element_id;
  end if;
 end if;
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
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if l_validate then
    raise hr_api.validate_enabled;
  end if;
  hr_utility.set_location(' Leaving:' || l_proc,20);
  --
exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to update_competence_element_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc, 30);
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_competence_element_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc, 35);
  when others then
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
    rollback to update_competence_element_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end update_competence_element;
-- ----------------------------------------------------------------------------
-- |------------------------< update_delivered_dates >------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_delivered_dates
  (p_activity_version_id          in     number
  ,p_old_start_date               in     date
  ,p_start_date                   in     date
  ,p_old_end_date                 in     date
  ,p_end_date                     in     date
  ,p_validate                     in     number    default hr_api.g_false_num
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'update_delivered_dates';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_delivered_dates_swi;
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
  hr_competence_element_api.update_delivered_dates
    (p_activity_version_id          => p_activity_version_id
    ,p_old_start_date               => p_old_start_date
    ,p_start_date                   => p_start_date
    ,p_old_end_date                 => p_old_end_date
    ,p_end_date                     => p_end_date
    ,p_validate                     => l_validate
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
    rollback to update_delivered_dates_swi;
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
    rollback to update_delivered_dates_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end update_delivered_dates;
-- ----------------------------------------------------------------------------
-- |---------------------< update_personal_comp_element >---------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_personal_comp_element
  (p_competence_element_id        in     number
  ,p_object_version_number        in out nocopy number
  ,p_proficiency_level_id         in     number    default hr_api.g_number
  ,p_effective_date_from          in     date      default hr_api.g_date
  ,p_effective_date_to            in     date      default hr_api.g_date
  ,p_source_of_proficiency_level  in     varchar2  default hr_api.g_varchar2
  ,p_certification_date           in     date      default hr_api.g_date
  ,p_certification_method         in     varchar2  default hr_api.g_varchar2
  ,p_next_certification_date      in     date      default hr_api.g_date
  ,p_comments                     in     varchar2  default hr_api.g_varchar2
  ,p_attribute_category           in     varchar2  default hr_api.g_varchar2
  ,p_attribute1                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute2                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute3                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute4                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute5                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute6                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute7                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute8                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute9                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute10                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute11                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute12                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute13                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute14                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute15                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute16                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute17                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute18                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute19                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute20                  in     varchar2  default hr_api.g_varchar2
  ,p_effective_date               in     date
  ,p_validate                     in     number    default hr_api.g_false_num
  ,p_ins_ovn                         out nocopy number
  ,p_ins_comp_id                     out nocopy number
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  l_object_version_number         number;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'update_personal_comp_element';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_personal_comp_ele_swi;
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
  hr_competence_element_api.update_personal_comp_element
    (p_competence_element_id        => p_competence_element_id
    ,p_object_version_number        => l_object_version_number
    ,p_proficiency_level_id         => p_proficiency_level_id
    ,p_effective_date_from          => p_effective_date_from
    ,p_effective_date_to            => p_effective_date_to
    ,p_source_of_proficiency_level  => p_source_of_proficiency_level
    ,p_certification_date           => p_certification_date
    ,p_certification_method         => p_certification_method
    ,p_next_certification_date      => p_next_certification_date
    ,p_comments                     => p_comments
    ,p_attribute_category           => p_attribute_category
    ,p_attribute1                   => p_attribute1
    ,p_attribute2                   => p_attribute2
    ,p_attribute3                   => p_attribute3
    ,p_attribute4                   => p_attribute4
    ,p_attribute5                   => p_attribute5
    ,p_attribute6                   => p_attribute6
    ,p_attribute7                   => p_attribute7
    ,p_attribute8                   => p_attribute8
    ,p_attribute9                   => p_attribute9
    ,p_attribute10                  => p_attribute10
    ,p_attribute11                  => p_attribute11
    ,p_attribute12                  => p_attribute12
    ,p_attribute13                  => p_attribute13
    ,p_attribute14                  => p_attribute14
    ,p_attribute15                  => p_attribute15
    ,p_attribute16                  => p_attribute16
    ,p_attribute17                  => p_attribute17
    ,p_attribute18                  => p_attribute18
    ,p_attribute19                  => p_attribute19
    ,p_attribute20                  => p_attribute20
    ,p_effective_date               => p_effective_date
    ,p_validate                     => l_validate
    ,p_ins_ovn                      => p_ins_ovn
    ,p_ins_comp_id                  => p_ins_comp_id
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
    rollback to update_personal_comp_ele_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_ins_ovn                      := null;
    p_ins_comp_id                  := null;
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
    rollback to update_personal_comp_ele_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_ins_ovn                      := null;
    p_ins_comp_id                  := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end update_personal_comp_element;

-- ----------------------------------------------------------------------------
-- |---------------------------< process_api >--------------------------------|
-- ----------------------------------------------------------------------------

Procedure process_api
( p_document            in         CLOB
 ,p_return_status       out nocopy VARCHAR2
 ,p_validate            in         number    default hr_api.g_false_num
 ,p_effective_date      in         date      default null
)
IS
   l_postState VARCHAR2(2);
   l_return_status VARCHAR2(1);
   l_commitElement xmldom.DOMElement;
   l_object_version_number number;
   l_parser xmlparser.Parser;
   l_CommitNode xmldom.DOMNode;
   l_proc    varchar2(72) := g_package || 'process_api';
   l_effective_date     date  :=  trunc(sysdate);

   --
   -- SSHR Attachment feature changes : 8691102
   --
    CURSOR get_person_for_comp_element
    (p_comp_elt_id IN NUMBER)
    IS
    select person_id from per_competence_elements
    where competence_element_id = p_comp_elt_id;

    l_person_id NUMBER;
    l_attach_status varchar2(80);

BEGIN

   hr_utility.set_location(' Entering:' || l_proc,10);
   hr_utility.set_location(' CLOB --> xmldom.DOMNode:' || l_proc,15);
   l_parser      := xmlparser.newParser;
   xmlparser.ParseCLOB(l_parser,p_document);
   l_CommitNode  := xmldom.makeNode(xmldom.getDocumentElement(xmlparser.getDocument(l_parser)));

   hr_utility.set_location('Extracting the PostState:' || l_proc,20);

   l_commitElement := xmldom.makeElement(l_CommitNode);
   l_postState := xmldom.getAttribute(l_commitElement, 'PS');
   l_object_version_number := hr_transaction_swi.getNumberValue(l_CommitNode,'ObjectVersionNumber');
--
   if p_effective_date is null
   then
   --
     l_effective_date := trunc(sysdate);
   --
   else
   --
     l_effective_date := p_effective_date;
   --
   end if;
--
   if l_postState = '0' then

        create_competence_element
      ( p_validate                     => p_validate
       ,p_competence_element_id        => hr_transaction_swi.getNumberValue(l_CommitNode,'CompetenceElementId',null)
       ,p_object_version_number        => l_object_version_number
       ,p_type                         => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Type',null)
       ,p_business_group_id            => hr_transaction_swi.getNumberValue(l_CommitNode,'BusinessGroupId',null)
       ,p_enterprise_id                => hr_transaction_swi.getNumberValue(l_CommitNode,'EnterpriseId',null)
       ,p_competence_id                => hr_transaction_swi.getNumberValue(l_CommitNode,'CompetenceId',null)
       ,p_proficiency_level_id         => hr_transaction_swi.getNumberValue(l_CommitNode,'ProficiencyLevelId',null)
       ,p_high_proficiency_level_id    => hr_transaction_swi.getNumberValue(l_CommitNode,'HighProficiencyLevelId',null)
       ,p_weighting_level_id           => hr_transaction_swi.getNumberValue(l_CommitNode,'WeightingLevelId',null)
       ,p_rating_level_id              => hr_transaction_swi.getNumberValue(l_CommitNode,'RatingLevelId',null)
       ,p_person_id                    => hr_transaction_swi.getNumberValue(l_CommitNode,'PersonId',null)
       ,p_job_id                       => hr_transaction_swi.getNumberValue(l_CommitNode,'JobId',null)
       ,p_valid_grade_id               => hr_transaction_swi.getNumberValue(l_CommitNode,'ValidGradeId',null)
       ,p_position_id                  => hr_transaction_swi.getNumberValue(l_CommitNode,'PositionId',null)
       ,p_organization_id              => hr_transaction_swi.getNumberValue(l_CommitNode,'OrganizationId',null)
       ,p_parent_competence_element_id => hr_transaction_swi.getNumberValue(l_CommitNode,'ParentCompetenceElementId',null)
       ,p_activity_version_id          => hr_transaction_swi.getNumberValue(l_CommitNode,'ActivityVersionId',null)
       ,p_assessment_id                => hr_transaction_swi.getNumberValue(l_CommitNode,'AssessmentId',null)
       ,p_assessment_type_id           => hr_transaction_swi.getNumberValue(l_CommitNode,'AssessmentTypeId',null)
       ,p_mandatory                    => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Mandatory',null)
       ,p_effective_date_from          => hr_transaction_swi.getDateValue(l_CommitNode,'EffectiveDateFrom',null)
       ,p_effective_date_to            => hr_transaction_swi.getDateValue(l_CommitNode,'EffectiveDateTo',null)
       ,p_group_competence_type        => hr_transaction_swi.getVarchar2Value(l_CommitNode,'GroupCompetenceType',null)
       ,p_competence_type              => hr_transaction_swi.getVarchar2Value(l_CommitNode,'CompetenceType',null)
       ,p_normal_elapse_duration       => hr_transaction_swi.getNumberValue(l_CommitNode,'NormalElapseDuration',null)
       ,p_normal_elapse_duration_unit  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'NormalElapseDurationUnit',null)
       ,p_sequence_number              => hr_transaction_swi.getNumberValue(l_CommitNode,'SequenceNumber',null)
       ,p_source_of_proficiency_level  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'SourceOfProficiencyLevel',null)
       ,p_line_score                   => hr_transaction_swi.getNumberValue(l_CommitNode,'LineScore',null)
       ,p_certification_date           => hr_transaction_swi.getDateValue(l_CommitNode,'CertificationDate',null)
       ,p_certification_method         => hr_transaction_swi.getVarchar2Value(l_CommitNode,'CertificationMethod',null)
       ,p_next_certification_date      => hr_transaction_swi.getDateValue(l_CommitNode,'NextCertificationDate',null)
       ,p_comments                     => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Comments',null)
       ,p_attribute_category           => hr_transaction_swi.getVarchar2Value(l_CommitNode,'AttributeCategory',null)
       ,p_attribute1                   => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute1',null)
       ,p_attribute2                   => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute2',null)
       ,p_attribute3                   => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute3',null)
       ,p_attribute4                   => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute4',null)
       ,p_attribute5                   => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute5',null)
       ,p_attribute6                   => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute6',null)
       ,p_attribute7                   => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute7',null)
       ,p_attribute8                   => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute8',null)
       ,p_attribute9                   => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute9',null)
       ,p_attribute10                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute10',null)
       ,p_attribute11                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute11',null)
       ,p_attribute12                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute12',null)
       ,p_attribute13                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute13',null)
       ,p_attribute14                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute14',null)
       ,p_attribute15                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute15',null)
       ,p_attribute16                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute16',null)
       ,p_attribute17                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute17',null)
       ,p_attribute18                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute18',null)
       ,p_attribute19                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute19',null)
       ,p_attribute20                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute20',null)
       ,p_effective_date               => l_effective_date
       ,p_object_id                    => hr_transaction_swi.getNumberValue(l_CommitNode,'ObjectId',null)
       ,p_object_name                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'ObjectName',null)
       ,p_party_id                     => hr_transaction_swi.getNumberValue(l_CommitNode,'PartyId',null)
       ,p_status                       => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Status',null)
       ,p_return_status                => l_return_status
      );

   elsif l_postState = '2' then


        update_competence_element
       (p_competence_element_id        => hr_transaction_swi.getNumberValue(l_CommitNode,'CompetenceElementId')
       ,p_object_version_number        => l_object_version_number
       ,p_competence_id                => hr_transaction_swi.getNumberValue(l_CommitNode,'CompetenceId')
       ,p_proficiency_level_id         => hr_transaction_swi.getNumberValue(l_CommitNode,'ProficiencyLevelId')
       ,p_high_proficiency_level_id    => hr_transaction_swi.getNumberValue(l_CommitNode,'HighProficiencyLevelId')
       ,p_weighting_level_id           => hr_transaction_swi.getNumberValue(l_CommitNode,'WeightingLevelId')
       ,p_rating_level_id              => hr_transaction_swi.getNumberValue(l_CommitNode,'RatingLevelId')
       ,p_mandatory                    => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Mandatory')
       ,p_effective_date_from          => hr_transaction_swi.getDateValue(l_CommitNode,'EffectiveDateFrom')
       ,p_effective_date_to            => hr_transaction_swi.getDateValue(l_CommitNode,'EffectiveDateTo')
       ,p_group_competence_type        => hr_transaction_swi.getVarchar2Value(l_CommitNode,'GroupCompetenceType')
       ,p_competence_type              => hr_transaction_swi.getVarchar2Value(l_CommitNode,'CompetenceType')
       ,p_normal_elapse_duration       => hr_transaction_swi.getNumberValue(l_CommitNode,'NormalElapseDuration')
       ,p_normal_elapse_duration_unit  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'NormalElapseDurationUnit')
       ,p_sequence_number              => hr_transaction_swi.getNumberValue(l_CommitNode,'SequenceNumber')
       ,p_source_of_proficiency_level  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'SourceOfProficiencyLevel')
       ,p_line_score                   => hr_transaction_swi.getNumberValue(l_CommitNode,'LineScore')
       ,p_certification_date           => hr_transaction_swi.getDateValue(l_CommitNode,'CertificationDate')
       ,p_certification_method         => hr_transaction_swi.getVarchar2Value(l_CommitNode,'CertificationMethod')
       ,p_next_certification_date      => hr_transaction_swi.getDateValue(l_CommitNode,'NextCertificationDate')
       ,p_comments                     => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Comments')
       ,p_attribute_category           => hr_transaction_swi.getVarchar2Value(l_CommitNode,'AttributeCategory')
       ,p_attribute1                   => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute1')
       ,p_attribute2                   => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute2')
       ,p_attribute3                   => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute3')
       ,p_attribute4                   => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute4')
       ,p_attribute5                   => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute5')
       ,p_attribute6                   => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute6')
       ,p_attribute7                   => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute7')
       ,p_attribute8                   => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute8')
       ,p_attribute9                   => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute9')
       ,p_attribute10                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute10')
       ,p_attribute11                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute11')
       ,p_attribute12                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute12')
       ,p_attribute13                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute13')
       ,p_attribute14                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute14')
       ,p_attribute15                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute15')
       ,p_attribute16                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute16')
       ,p_attribute17                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute17')
       ,p_attribute18                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute18')
       ,p_attribute19                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute19')
       ,p_attribute20                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute20')
       ,p_effective_date               => l_effective_date
       ,p_validate                     => p_validate
       ,p_party_id                     => hr_transaction_swi.getNumberValue(l_CommitNode,'PartyId')
       ,p_status                       => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Status',null)
       ,p_return_status                => l_return_status
       ,p_datetrack_update_mode        => hr_transaction_swi.getVarchar2Value(l_CommitNode,'DatetrackUpdate',hr_api.g_correction)
      );

   elsif l_postState = '3' then

        delete_competence_element
      ( p_validate                     => p_validate
       ,p_competence_element_id        => hr_transaction_swi.getNumberValue(l_CommitNode,'CompetenceElementId')
       ,p_object_version_number        => l_object_version_number
       ,p_return_status                => l_return_status
      );



   end if;
   p_return_status := l_return_status;

       --
       -- SSHR Attachment feature changes : 8691102
       OPEN  get_person_for_comp_element(hr_transaction_swi.getNumberValue(l_CommitNode,'CompetenceElementId'));
       FETCH get_person_for_comp_element INTO l_person_id;
       CLOSE get_person_for_comp_element;

       hr_utility.set_location('merge_attachments Start : l_person_id = ' || l_person_id || ' ' ||l_proc, 30);

       HR_UTIL_MISC_SS.merge_attachments( p_dest_entity_name => 'PER_PEOPLE_F'
                           ,p_dest_pk1_value => l_person_id
                           ,p_return_status => l_attach_status);

      hr_utility.set_location('merge_attachments End: l_attach_status = ' || l_attach_status || ' ' ||l_proc, 35);

      hr_utility.set_location('Exiting:' || l_proc,40);

END process_api;
end hr_competence_element_swi;

/
