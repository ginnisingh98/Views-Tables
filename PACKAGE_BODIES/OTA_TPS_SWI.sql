--------------------------------------------------------
--  DDL for Package Body OTA_TPS_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_TPS_SWI" AS
/* $Header: ottpsswi.pkb 115.6 2004/08/31 17:31:14 asud noship $ */
--
-- Package variables
--
g_package  VARCHAR2(33) := 'ota_tps_swi.';
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_training_plan >-------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_training_plan
  (p_validate                     IN     NUMBER    DEFAULT hr_api.g_false_num
  ,p_effective_date               IN     DATE
  ,p_business_group_id            IN     NUMBER
  ,p_time_period_id               IN     NUMBER   DEFAULT NULL
  ,p_plan_status_type_id          IN     VARCHAR2
  ,p_organization_id              IN     NUMBER    DEFAULT NULL
  ,p_person_id                    IN     NUMBER    DEFAULT NULL
  ,p_budget_currency              IN     VARCHAR2  DEFAULT NULL
  ,p_name                         IN     VARCHAR2
  ,p_description                  IN     VARCHAR2  DEFAULT NULL
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
  ,p_plan_source                  IN     VARCHAR2  DEFAULT NULL
  ,p_start_date                   IN     DATE      DEFAULT NULL
  ,p_end_date                     IN     DATE      DEFAULT NULL
  ,p_training_plan_id             IN     NUMBER
  ,p_creator_person_id            IN     NUMBER
  ,p_additional_member_flag       IN     VARCHAR2  DEFAULT NULL
  ,p_learning_path_id             IN     NUMBER    DEFAULT NULL
  -- Modified for Bug#3479186
  ,p_contact_id             IN     NUMBER    DEFAULT NULL
  ,p_object_version_NUMBER        OUT NOCOPY NUMBER
  ,p_return_status                OUT NOCOPY VARCHAR2
  ) IS
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  l_budget_currency               VARCHAR2(15);
  l_plan_status_type_id           VARCHAR2(30);
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_training_plan_id             number;
  l_proc    VARCHAR2(72) := g_package ||'create_training_plan';

-- for disabling the descriptive flex field
l_add_struct_d hr_dflex_utility.l_ignore_dfcode_varray :=
                           hr_dflex_utility.l_ignore_dfcode_varray();


BEGIN
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  SAVEPOINT create_training_plan_swi;
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
  l_validate := hr_api.constant_to_boolean(p_constant_value => p_validate);
  --
  -- Register Surrogate ID or user key values
  --
  ota_tps_ins.set_base_key_value
    (p_training_plan_id => p_training_plan_id
    );
  --
  -- Set default values
  --
  l_budget_currency := hr_general.default_currency_code
                        (p_business_group_id => p_business_group_id);

  l_plan_status_type_id := 'ACTIVE';

 --Ignore dff validation if being called from SS as DFF not suppoted in SS
     IF p_plan_source = 'TALENT_MGMT' or p_learning_path_id IS NOT NULL then
        l_add_struct_d.extend(1);
        l_add_struct_d(l_add_struct_d.count) := 'OTA_TRAINING_PLANS';

        hr_dflex_utility.create_ignore_df_validation(p_rec => l_add_struct_d);
    END IF;


  --
  -- Call API
  --
  ota_tps_api.create_training_plan
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_business_group_id            => p_business_group_id
    ,p_time_period_id               => p_time_period_id
    ,p_plan_status_type_id          => l_plan_status_type_id
    ,p_organization_id              => p_organization_id
    ,p_person_id                    => p_person_id
    ,p_budget_currency              => l_budget_currency
    ,p_name                         => p_name
    ,p_description                  => p_description
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
    ,p_plan_source                  => p_plan_source
    ,p_start_date                   => p_start_date
    ,p_end_date                     => p_end_date
    ,p_creator_person_id            => p_creator_person_id
    ,p_training_plan_id             => l_training_plan_id
    ,p_object_version_NUMBER        => p_object_version_number
    ,p_additional_member_flag       => p_additional_member_flag
    ,p_learning_path_id             => p_learning_path_id
    ,p_contact_id                         => p_contact_id
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
    ROLLBACK TO create_training_plan_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number        := NULL;
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
    ROLLBACK TO create_training_plan_swi;
    IF hr_multi_message.unexpected_error_add(l_proc) THEN
       hr_utility.set_location(' Leaving:' || l_proc,40);
       RAISE;
    END IF;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_object_version_number        := NULL;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);

END create_training_plan;
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_training_plan >-------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_training_plan
  (p_validate                     IN     NUMBER    DEFAULT hr_api.g_false_num
  ,p_training_plan_id             IN     NUMBER
  ,p_object_version_NUMBER        IN     NUMBER
  ,p_return_status                OUT NOCOPY VARCHAR2
  ) IS
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Other variables
  l_proc    VARCHAR2(72) := g_package ||'delete_training_plan';

BEGIN
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  SAVEPOINT delete_training_plan_swi;
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
  ota_tps_api.delete_training_plan
    (p_validate                     => l_validate
    ,p_training_plan_id             => p_training_plan_id
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
    ROLLBACK TO delete_training_plan_swi;
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
    ROLLBACK TO delete_training_plan_swi;
    IF hr_multi_message.unexpected_error_add(l_proc) THEN
       hr_utility.set_location(' Leaving:' || l_proc,40);
       RAISE;
    END IF;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
END delete_training_plan;
-- ----------------------------------------------------------------------------
-- |-------------------------< update_training_plan >-------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_training_plan
  (p_validate                     IN     NUMBER    DEFAULT hr_api.g_false_num
  ,p_effective_date               IN     DATE
  ,p_training_plan_id             IN     NUMBER
  ,p_object_version_number        IN OUT NOCOPY NUMBER
  ,p_time_period_id               IN     NUMBER    DEFAULT hr_api.g_number
  ,p_plan_status_type_id          IN     VARCHAR2
  ,p_budget_currency              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_name                         IN     VARCHAR2
  ,p_description                  IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
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
  ,p_plan_source                  IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_start_date                   IN     DATE      DEFAULT hr_api.g_date
  ,p_end_date                     IN     DATE      DEFAULT hr_api.g_date
  ,p_creator_person_id            IN    NUMBER
  ,p_additional_member_flag       IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_learning_path_id             IN     NUMBER    DEFAULT hr_api.g_number
  ,p_contact_id             IN     NUMBER    DEFAULT hr_api.g_number
  ,p_return_status                OUT NOCOPY VARCHAR2
  ) IS
  --
  -- Variables for API Boolean parameters
  l_validate                      BOOLEAN;
  --
  -- Variables for IN/OUT parameters
  l_object_version_NUMBER         NUMBER;
  --
  -- Other variables
  l_proc    VARCHAR2(72) := g_package ||'update_training_plan';

BEGIN
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  SAVEPOINT update_training_plan_swi;
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
  ota_tps_api.update_training_plan
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_training_plan_id             => p_training_plan_id
    ,p_object_version_NUMBER        => p_object_version_number
    ,p_time_period_id               => p_time_period_id
    ,p_plan_status_type_id          => p_plan_status_type_id
    ,p_budget_currency              => p_budget_currency
    ,p_name                         => p_name
    ,p_description                  => p_description
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
    ,p_plan_source                  => p_plan_source
    ,p_start_date                   => p_start_date
    ,p_end_date                     => p_end_date
    ,p_creator_person_id            => p_creator_person_id
    ,p_additional_member_flag       => p_additional_member_flag
    ,p_learning_path_id             => p_learning_path_id
    ,p_contact_id                         => p_contact_id
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
    ROLLBACK TO update_training_plan_swi;
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
    ROLLBACK TO update_training_plan_swi;
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
END update_training_plan;
END ota_tps_swi;

/
