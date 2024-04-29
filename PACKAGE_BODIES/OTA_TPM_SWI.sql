--------------------------------------------------------
--  DDL for Package Body OTA_TPM_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_TPM_SWI" AS
/* $Header: ottpmswi.pkb 115.8 2004/09/01 13:44:07 asud noship $ */
--
-- Package variables
--
g_package  VARCHAR2(33) := 'ota_tpm_swi.';
--

-- ----------------------------------------------------------------------------
-- |----------------------< create_training_plan_member >---------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_training_plan_member
  (p_validate                     IN     NUMBER    DEFAULT hr_api.g_false_num
  ,p_effective_date               IN     date
  ,p_business_group_id            IN     number
  ,p_training_plan_id             IN     number    DEFAULT NULL
  ,p_activity_version_id          IN     NUMBER
  ,p_activity_definition_id       IN     NUMBER    DEFAULT NULL
  ,p_member_status_type_id        IN     VARCHAR2  DEFAULT NULL
  ,p_target_completion_date       IN     date
  ,p_attribute_category           IN     VARCHAR2  DEFAULT NULL
  ,p_attribute1                   IN     VARCHAR2  DEFAULT NULL
  ,p_attribute2                   IN     VARCHAR2  DEFAULT NULL
  ,p_attribute3                   IN     VARCHAR2  DEFAULT NULL
  ,p_attribute4                   IN     VARCHAR2  DEFAULT NULL
  ,p_attribute5                   IN     VARCHAR2  DEFAULT NULL
  ,p_attribute6                   IN     VARCHAR2  DEFAULT NULL
  ,p_attribute7                   IN     VARCHAR2  DEFAULT NULL
  ,p_attribute8                   IN     VARCHAR2  DEFAULT NULL
  ,p_attribute9                   IN     VARCHAR2  DEFAULT NULL
  ,p_attribute10                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute11                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute12                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute13                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute14                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute15                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute16                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute17                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute18                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute19                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute20                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute21                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute22                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute23                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute24                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute25                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute26                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute27                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute28                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute29                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute30                  IN     VARCHAR2  DEFAULT NULL
  ,p_assignment_id                IN     NUMBER    DEFAULT NULL
  ,p_source_id                    IN     NUMBER    DEFAULT NULL
  ,p_source_function              IN     VARCHAR2  DEFAULT NULL
  ,p_cancellation_reason          IN     VARCHAR2  DEFAULT NULL
  ,p_earliest_start_date          IN     date
  ,p_training_plan_member_id      IN     number
  ,p_creator_person_id            IN    number
  ,p_person_id                    IN    NUMBER    DEFAULT NULL
  ,p_plan_start_date              IN    DATE    DEFAULT NULL
  ,p_object_version_NUMBER           OUT NOCOPY number
  ,p_return_status                   OUT NOCOPY VARCHAR2
  ) IS
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_training_plan_member_id      number;
  l_training_plan_id             NUMBER := p_training_plan_id;
  l_object_version_number        NUMBER;
  l_return_status                varchar2(30);
  l_member_status_type_id        varchar2(30) := p_member_status_type_id;
  l_person_full_name             varchar2(240);
  l_exists                       NUMBER;
  -- for disabling the descriptive flex field
l_add_struct_d hr_dflex_utility.l_ignore_dfcode_varray :=
                           hr_dflex_utility.l_ignore_dfcode_varray();

  l_proc    VARCHAR2(72) := g_package ||'create_training_plan_member';
  l_lp_id       ota_training_plans.learning_path_id%TYPE := null;

  cursor csr_person_full_name is
    select ppf.full_name
    from per_all_people_f ppf
    where ppf.person_id = p_person_id
      and p_effective_date between ppf.effective_start_date and ppf.effective_end_date;

 Cursor csr_get_lp_id IS
        Select learning_path_id
        From ota_training_plans
        Where training_plan_id = p_training_plan_id;

BEGIN
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  SAVEPOINT create_trng_plan_member_swi;
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
  -- Check if the call is from SSHR - Appraisal / Suitability Matching / Succession Planning
  --
  if (p_training_plan_id is null) then

      -- SSHR call should have person Id. Mandatory check for personId.
      hr_api.mandatory_arg_error
          (p_api_name       =>  l_proc
          ,p_argument       => 'p_person_id'
          ,p_argument_value =>  p_person_id
          );

             l_exists := ota_trng_plan_util_ss.chk_src_func_tlntmgt(p_person_id  => p_person_id,
                                                        p_earliest_start_date    => p_earliest_start_date,
                                                        p_target_completion_date => p_target_completion_date,
                                                      -- Added for Bug#3108246
                                                        p_business_group_id      => p_business_group_id);

     -- value of 0 implies there is no training plan of type talent Managment
     -- existing for the training plan member being added.
     -- so first create a training plan
    IF l_exists = 0 THEN

     open csr_person_full_name;
     fetch csr_person_full_name into l_person_full_name;
     close csr_person_full_name;

     ota_tps_swi.create_training_plan
     (  p_validate                     => p_validate
       ,p_effective_date               => p_effective_date
       ,p_business_group_id            => p_business_group_id
       ,p_plan_status_type_id          => 'ACTIVE'
       ,p_person_id                    => p_person_id
       ,p_budget_currency              => hr_general.default_currency_code(p_business_group_id => p_business_group_id)
       ,p_name                         => l_person_full_name ||' Talent Management '||nvl(p_plan_start_date,p_earliest_start_date)
       ,p_plan_source                  => 'TALENT_MGMT'
       ,p_start_date                   => nvl(p_plan_start_date,p_earliest_start_date)
       ,p_end_date                     => hr_api.g_eot
       ,p_training_plan_id             => l_training_plan_id
       ,p_creator_person_id            => p_creator_person_id
       ,p_object_version_NUMBER        => l_object_version_number
       ,p_return_status                => l_return_status
     );

     -- If Training Plan is not created, rollback and return
     if (l_return_status = 'E') then
        ROLLBACK TO create_trng_plan_member_swi;
        p_object_version_NUMBER        := NULL;
        p_return_status := hr_multi_message.get_return_status_disable;
        return;
    end if;

      -- Fetch the Training Plan Id Created.
      l_training_plan_id := ota_trng_plan_util_ss.chk_src_func_tlntmgt(
                                            p_person_id              => p_person_id,
                                            p_earliest_start_date    => p_earliest_start_date,
                                            p_target_completion_date => p_target_completion_date,
                                          -- Added for Bug#3018246
                                            p_business_group_id      => p_business_group_id);

   ELSE
     l_training_plan_id := l_exists;
  END IF;  -- End Create Training Plan


    -- Default PLAN MEMBER STATUS to OTA_AWAITING_APPROVAL if the Call is from SSHR
    if p_member_status_type_id is null then
          l_member_status_type_id := 'OTA_AWAITING_APPROVAL';
    end if;
  END IF;  -- End check for call from SSHR /OTA

       FOR rec IN csr_get_lp_id
      LOOP
           l_lp_id :=rec.learning_path_id;
           EXIT;
       END LOOP;

	 -- Ignore dff validation if being called from sshr

      IF  l_member_status_type_id = 'OTA_AWAITING_APPROVAL' OR l_lp_id is not null THEN

        l_add_struct_d.extend(1);
        l_add_struct_d(l_add_struct_d.count) := 'OTA_TRAINING_PLAN_MEMBERS';

        hr_dflex_utility.create_ignore_df_validation(p_rec => l_add_struct_d);

      END IF;


  --
  -- Register Surrogate ID or user key values
  --
  ota_tpm_ins.set_base_key_value
    (p_training_plan_member_id => p_training_plan_member_id
    );
  --
  -- Call API
  --
  ota_tpm_api.create_training_plan_member
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_business_group_id            => p_business_group_id
    ,p_training_plan_id             => l_training_plan_id
    ,p_activity_version_id          => p_activity_version_id
    ,p_activity_definition_id       => p_activity_definition_id
    ,p_member_status_type_id        => l_member_status_type_id
    ,p_target_completion_date       => p_target_completion_date
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
    ,p_attribute21                  => p_attribute21
    ,p_attribute22                  => p_attribute22
    ,p_attribute23                  => p_attribute23
    ,p_attribute24                  => p_attribute24
    ,p_attribute25                  => p_attribute25
    ,p_attribute26                  => p_attribute26
    ,p_attribute27                  => p_attribute27
    ,p_attribute28                  => p_attribute28
    ,p_attribute29                  => p_attribute29
    ,p_attribute30                  => p_attribute30
    ,p_assignment_id                => p_assignment_id
    ,p_source_id                    => p_source_id
    ,p_source_function              => p_source_function
    ,p_cancellation_reason          => p_cancellation_reason
    ,p_earliest_start_date          => p_earliest_start_date
    ,p_training_plan_member_id      => l_training_plan_member_id
    ,p_object_version_NUMBER        => p_object_version_number
    ,p_creator_person_id            => p_creator_person_id
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
EXCEPTION
  WHEN hr_multi_message.error_message_exist THEN
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    ROLLBACK TO create_trng_plan_member_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_NUMBER        := NULL;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc, 30);

  WHEN others THEN
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
    ROLLBACK TO create_trng_plan_member_swi;
    IF hr_multi_message.unexpected_error_add(l_proc) THEN
       hr_utility.set_location(' Leaving:' || l_proc,40);
       RAISE;
    END IF;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_object_version_NUMBER        := NULL;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
END create_training_plan_member;


-- ----------------------------------------------------------------------------
-- |----------------------< delete_training_plan_member >---------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_training_plan_member
  (p_validate                     IN     NUMBER    DEFAULT hr_api.g_false_num
  ,p_training_plan_member_id      IN     number
  ,p_object_version_NUMBER        IN     number
  ,p_return_status                   OUT NOCOPY VARCHAR2
  ) IS
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    VARCHAR2(72) := g_package ||'delete_training_plan_member';
BEGIN
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  SAVEPOINT delete_trng_plan_member_swi;
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
  ota_tpm_api.delete_training_plan_member
    (p_validate                     => l_validate
    ,p_training_plan_member_id      => p_training_plan_member_id
    ,p_object_version_NUMBER        => p_object_version_number
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
EXCEPTION
  WHEN hr_multi_message.error_message_exist THEN
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    ROLLBACK TO delete_trng_plan_member_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc, 30);
  WHEN others THEN
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
    ROLLBACK TO delete_trng_plan_member_swi;
    IF hr_multi_message.unexpected_error_add(l_proc) THEN
       hr_utility.set_location(' Leaving:' || l_proc,40);
       RAISE;
    END IF;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
END delete_training_plan_member;
-- ----------------------------------------------------------------------------
-- |----------------------< update_training_plan_member >---------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_training_plan_member
  (p_validate                     IN     NUMBER    DEFAULT hr_api.g_false_num
  ,p_effective_date               IN     date
  ,p_training_plan_member_id      IN     number
  ,p_object_version_NUMBER        IN OUT NOCOPY number
  ,p_activity_version_id          IN     NUMBER    DEFAULT hr_api.g_number
  ,p_activity_definition_id       IN     NUMBER    DEFAULT hr_api.g_number
  ,p_member_status_type_id        IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_target_completion_date       IN     date      DEFAULT hr_api.g_date
  ,p_attribute_category           IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute1                   IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute2                   IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute3                   IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute4                   IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute5                   IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute6                   IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute7                   IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute8                   IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute9                   IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute10                  IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute11                  IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute12                  IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute13                  IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute14                  IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute15                  IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute16                  IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute17                  IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute18                  IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute19                  IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute20                  IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute21                  IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute22                  IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute23                  IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute24                  IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute25                  IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute26                  IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute27                  IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute28                  IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute29                  IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute30                  IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_assignment_id                IN     NUMBER    DEFAULT hr_api.g_number
  ,p_source_id                    IN     NUMBER    DEFAULT hr_api.g_number
  ,p_source_function              IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_cancellation_reason          IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_earliest_start_date          IN     date      DEFAULT hr_api.g_date
  ,p_creator_person_id             IN    NUMBER
  ,p_return_status                   OUT NOCOPY VARCHAR2
  ) IS
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  l_object_version_NUMBER         number;
  --
  -- Other variables
  l_proc    VARCHAR2(72) := g_package ||'update_training_plan_member';

BEGIN
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  SAVEPOINT update_trng_plan_member_swi;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  l_object_version_NUMBER         := p_object_version_number;
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
  ota_tpm_api.update_training_plan_member
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_training_plan_member_id      => p_training_plan_member_id
    ,p_object_version_NUMBER        => p_object_version_number
    ,p_activity_version_id          => p_activity_version_id
    ,p_activity_definition_id       => p_activity_definition_id
    ,p_member_status_type_id        => p_member_status_type_id
    ,p_target_completion_date       => p_target_completion_date
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
    ,p_attribute21                  => p_attribute21
    ,p_attribute22                  => p_attribute22
    ,p_attribute23                  => p_attribute23
    ,p_attribute24                  => p_attribute24
    ,p_attribute25                  => p_attribute25
    ,p_attribute26                  => p_attribute26
    ,p_attribute27                  => p_attribute27
    ,p_attribute28                  => p_attribute28
    ,p_attribute29                  => p_attribute29
    ,p_attribute30                  => p_attribute30
    ,p_assignment_id                => p_assignment_id
    ,p_source_id                    => p_source_id
    ,p_source_function              => p_source_function
    ,p_cancellation_reason          => p_cancellation_reason
    ,p_earliest_start_date          => p_earliest_start_date
    ,p_creator_person_id           => p_creator_person_id
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
EXCEPTION
  WHEN hr_multi_message.error_message_exist THEN
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    ROLLBACK TO update_trng_plan_member_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_NUMBER        := l_object_version_number;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc, 30);
  WHEN others THEN
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
    ROLLBACK TO update_trng_plan_member_swi;
    IF hr_multi_message.unexpected_error_add(l_proc) THEN
       hr_utility.set_location(' Leaving:' || l_proc,40);
       RAISE;
    END IF;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_object_version_NUMBER        := l_object_version_number;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
END update_training_plan_member;
END ota_tpm_swi;

/
