--------------------------------------------------------
--  DDL for Package Body HR_ASSESSMENT_TYPES_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_ASSESSMENT_TYPES_SWI" As
/* $Header: peastswi.pkb 120.0 2006/02/09 08:33 sansingh noship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'hr_assessment_types_swi.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_assessment_type >------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_assessment_type
  (p_assessment_type_id           in     number
  ,p_name                         in     varchar2
  ,p_business_group_id            in     number
  ,p_description                  in     varchar2  default null
  ,p_rating_scale_id              in     number    default null
  ,p_weighting_scale_id           in     number    default null
  ,p_rating_scale_comment         in     varchar2  default null
  ,p_weighting_scale_comment      in     varchar2  default null
  ,p_assessment_classification    in     varchar2
  ,p_display_assessment_comments  in     varchar2  default null
  ,p_date_from                    in     date
  ,p_date_to                      in     date
  ,p_comments                     in     varchar2  default null
  ,p_instructions                 in     varchar2  default null
  ,p_weighting_classification     in     varchar2  default null
  ,p_line_score_formula           in     varchar2  default null
  ,p_total_score_formula          in     varchar2  default null
  ,p_object_version_number           out nocopy number
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
  ,p_type                         in     varchar2
  ,p_line_score_formula_id        in     number    default null
  ,p_default_job_competencies     in     varchar2  default null
  ,p_available_flag               in     varchar2  default null
  ,p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'create_assessment_type';
  l_assessment_type_id    per_assessment_types.assessment_type_id%Type;
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_assessment_type_swi;
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
  per_ast_ins.set_base_key_value(
    p_assessment_type_id  => p_assessment_type_id);

  --
  -- Call API
  --
  hr_assessment_types_api.create_assessment_type
    (p_assessment_type_id           => l_assessment_type_id
    ,p_name                         => p_name
    ,p_business_group_id            => p_business_group_id
    ,p_description                  => p_description
    ,p_rating_scale_id              => p_rating_scale_id
    ,p_weighting_scale_id           => p_weighting_scale_id
    ,p_rating_scale_comment         => p_rating_scale_comment
    ,p_weighting_scale_comment      => p_weighting_scale_comment
    ,p_assessment_classification    => p_assessment_classification
    ,p_display_assessment_comments  => p_display_assessment_comments
    ,p_date_from                    => p_date_from
    ,p_date_to                      => p_date_to
    ,p_comments                     => p_comments
    ,p_instructions                 => p_instructions
    ,p_weighting_classification     => p_weighting_classification
    ,p_line_score_formula           => p_line_score_formula
    ,p_total_score_formula          => p_total_score_formula
    ,p_object_version_number        => p_object_version_number
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
    ,p_type                         => p_type
    ,p_line_score_formula_id        => p_line_score_formula_id
    ,p_default_job_competencies     => p_default_job_competencies
    ,p_available_flag               => p_available_flag
    ,p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
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
    rollback to create_assessment_type_swi;
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
    rollback to create_assessment_type_swi;
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
end create_assessment_type;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_assessment_type >------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_assessment_type
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_assessment_type_id           in     number
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
  l_proc    varchar2(72) := g_package ||'delete_assessment_type';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_assessment_type_swi;
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
  hr_assessment_types_api.delete_assessment_type
    (p_validate                     => l_validate
    ,p_assessment_type_id           => p_assessment_type_id
    ,p_object_version_number        => p_object_version_number
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
    rollback to delete_assessment_type_swi;
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
    rollback to delete_assessment_type_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end delete_assessment_type;
-- ----------------------------------------------------------------------------
-- |------------------------< update_assessment_type >------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_assessment_type
  (p_assessment_type_id           in     number
  ,p_name                         in     varchar2  default hr_api.g_varchar2
  ,p_description                  in     varchar2  default hr_api.g_varchar2
  ,p_rating_scale_id              in     number    default hr_api.g_number
  ,p_weighting_scale_id           in     number    default hr_api.g_number
  ,p_rating_scale_comment         in     varchar2  default hr_api.g_varchar2
  ,p_weighting_scale_comment      in     varchar2  default hr_api.g_varchar2
  ,p_assessment_classification    in     varchar2  default hr_api.g_varchar2
  ,p_display_assessment_comments  in     varchar2  default hr_api.g_varchar2
  ,p_date_from                    in     date      default hr_api.g_date
  ,p_date_to                      in     date      default hr_api.g_date
  ,p_comments                     in     varchar2  default hr_api.g_varchar2
  ,p_instructions                 in     varchar2  default hr_api.g_varchar2
  ,p_weighting_classification     in     varchar2  default hr_api.g_varchar2
  ,p_line_score_formula           in     varchar2  default hr_api.g_varchar2
  ,p_total_score_formula          in     varchar2  default hr_api.g_varchar2
  ,p_object_version_number        in out nocopy number
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
  ,p_type                         in     varchar2  default hr_api.g_varchar2
  ,p_line_score_formula_id        in     number    default hr_api.g_number
  ,p_default_job_competencies     in     varchar2  default hr_api.g_varchar2
  ,p_available_flag               in     varchar2  default hr_api.g_varchar2
  ,p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
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
  l_proc    varchar2(72) := g_package ||'update_assessment_type';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_assessment_type_swi;
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
  hr_assessment_types_api.update_assessment_type
    (p_assessment_type_id           => p_assessment_type_id
    ,p_name                         => p_name
    ,p_description                  => p_description
    ,p_rating_scale_id              => p_rating_scale_id
    ,p_weighting_scale_id           => p_weighting_scale_id
    ,p_rating_scale_comment         => p_rating_scale_comment
    ,p_weighting_scale_comment      => p_weighting_scale_comment
    ,p_assessment_classification    => p_assessment_classification
    ,p_display_assessment_comments  => p_display_assessment_comments
    ,p_date_from                    => p_date_from
    ,p_date_to                      => p_date_to
    ,p_comments                     => p_comments
    ,p_instructions                 => p_instructions
    ,p_weighting_classification     => p_weighting_classification
    ,p_line_score_formula           => p_line_score_formula
    ,p_total_score_formula          => p_total_score_formula
    ,p_object_version_number        => p_object_version_number
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
    ,p_type                         => p_type
    ,p_line_score_formula_id        => p_line_score_formula_id
    ,p_default_job_competencies     => p_default_job_competencies
    ,p_available_flag               => p_available_flag
    ,p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
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
    rollback to update_assessment_type_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
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
    rollback to update_assessment_type_swi;
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
end update_assessment_type;
end hr_assessment_types_swi;

/
