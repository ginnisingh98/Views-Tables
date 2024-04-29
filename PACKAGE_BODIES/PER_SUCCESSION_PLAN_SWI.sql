--------------------------------------------------------
--  DDL for Package Body PER_SUCCESSION_PLAN_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_SUCCESSION_PLAN_SWI" AS
/* $Header: pesucswi.pkb 120.0.12010000.4 2010/02/13 19:34:50 schowdhu ship $ */
--
-- Package variables
--
   g_package   VARCHAR2 (33) := 'per_succession_plan_swi.';

--
-- ----------------------------------------------------------------------------
-- |------------------------< create_succession_plan >------------------------|
-- ----------------------------------------------------------------------------
   PROCEDURE create_succession_plan (
      p_validate                  IN              NUMBER DEFAULT hr_api.g_false_num,
      p_person_id                 IN              NUMBER,
      p_position_id               IN              NUMBER DEFAULT NULL,
      p_business_group_id         IN              NUMBER,
      p_start_date                IN              DATE,
      p_time_scale                IN              VARCHAR2,
      p_end_date                  IN              DATE DEFAULT NULL,
      p_available_for_promotion   IN              VARCHAR2 DEFAULT NULL,
      p_manager_comments          IN              VARCHAR2 DEFAULT NULL,
      p_attribute_category        IN              VARCHAR2 DEFAULT NULL,
      p_attribute1                IN              VARCHAR2 DEFAULT NULL,
      p_attribute2                IN              VARCHAR2 DEFAULT NULL,
      p_attribute3                IN              VARCHAR2 DEFAULT NULL,
      p_attribute4                IN              VARCHAR2 DEFAULT NULL,
      p_attribute5                IN              VARCHAR2 DEFAULT NULL,
      p_attribute6                IN              VARCHAR2 DEFAULT NULL,
      p_attribute7                IN              VARCHAR2 DEFAULT NULL,
      p_attribute8                IN              VARCHAR2 DEFAULT NULL,
      p_attribute9                IN              VARCHAR2 DEFAULT NULL,
      p_attribute10               IN              VARCHAR2 DEFAULT NULL,
      p_attribute11               IN              VARCHAR2 DEFAULT NULL,
      p_attribute12               IN              VARCHAR2 DEFAULT NULL,
      p_attribute13               IN              VARCHAR2 DEFAULT NULL,
      p_attribute14               IN              VARCHAR2 DEFAULT NULL,
      p_attribute15               IN              VARCHAR2 DEFAULT NULL,
      p_attribute16               IN              VARCHAR2 DEFAULT NULL,
      p_attribute17               IN              VARCHAR2 DEFAULT NULL,
      p_attribute18               IN              VARCHAR2 DEFAULT NULL,
      p_attribute19               IN              VARCHAR2 DEFAULT NULL,
      p_attribute20               IN              VARCHAR2 DEFAULT NULL,
      p_effective_date            IN              DATE,
      p_job_id                    IN              NUMBER DEFAULT NULL,
      p_successee_person_id       IN              NUMBER DEFAULT NULL,
      p_person_rank               IN              NUMBER,
      p_performance               IN              VARCHAR2,
      p_plan_status               IN              VARCHAR2 DEFAULT NULL,
      p_readiness_percentage      IN              NUMBER DEFAULT NULL,
      p_succession_plan_id        IN              NUMBER,
      p_object_version_number     OUT NOCOPY      NUMBER,
      p_return_status             OUT NOCOPY      VARCHAR2
   )
   IS
      --
      -- Variables for API Boolean parameters
      l_validate             BOOLEAN;
      l_succession_plan_id   NUMBER;
      --
      -- Variables for IN/OUT parameters
      --
      -- Other variables
      l_proc                 VARCHAR2 (72) := g_package || 'create_succession_plan';
   BEGIN
      hr_utility.set_location (' Entering:' || l_proc, 10);
      --
      -- Issue a savepoint
      --
      SAVEPOINT create_succession_plan_swi;
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
      l_validate                 := hr_api.constant_to_boolean (p_constant_value => p_validate);
      --
      -- Register Surrogate ID or user key values
      --
      per_suc_ins.set_base_key_value (p_succession_plan_id => p_succession_plan_id);
      --
      -- Call API
      --
      per_succession_plan_api.create_succession_plan
                                           (p_validate                     => l_validate,
                                            p_person_id                    => p_person_id,
                                            p_position_id                  => p_position_id,
                                            p_business_group_id            => p_business_group_id,
                                            p_start_date                   => p_start_date,
                                            p_time_scale                   => p_time_scale,
                                            p_end_date                     => p_end_date,
                                            p_available_for_promotion      => p_available_for_promotion,
                                            p_manager_comments             => p_manager_comments,
                                            p_attribute_category           => p_attribute_category,
                                            p_attribute1                   => p_attribute1,
                                            p_attribute2                   => p_attribute2,
                                            p_attribute3                   => p_attribute3,
                                            p_attribute4                   => p_attribute4,
                                            p_attribute5                   => p_attribute5,
                                            p_attribute6                   => p_attribute6,
                                            p_attribute7                   => p_attribute7,
                                            p_attribute8                   => p_attribute8,
                                            p_attribute9                   => p_attribute9,
                                            p_attribute10                  => p_attribute10,
                                            p_attribute11                  => p_attribute11,
                                            p_attribute12                  => p_attribute12,
                                            p_attribute13                  => p_attribute13,
                                            p_attribute14                  => p_attribute14,
                                            p_attribute15                  => p_attribute15,
                                            p_attribute16                  => p_attribute16,
                                            p_attribute17                  => p_attribute17,
                                            p_attribute18                  => p_attribute18,
                                            p_attribute19                  => p_attribute19,
                                            p_attribute20                  => p_attribute20,
                                            p_effective_date               => p_effective_date,
                                            p_job_id                       => p_job_id,
                                            p_person_rank                  => p_person_rank,
                                            p_performance                  => p_performance,
                                            p_plan_status                  => p_plan_status,
                                            p_readiness_percentage         => p_readiness_percentage,
                                            p_successee_person_id          => p_successee_person_id,
                                            p_succession_plan_id           => l_succession_plan_id,
                                            p_object_version_number        => p_object_version_number
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
      p_return_status            := hr_multi_message.get_return_status_disable;
      hr_utility.set_location (' Leaving:' || l_proc, 20);
   --
   EXCEPTION
      WHEN hr_multi_message.error_message_exist
      THEN
         --
         -- Catch the Multiple Message List exception which
         -- indicates API processing has been aborted because
         -- at least one message exists in the list.
         --
         ROLLBACK TO create_succession_plan_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
--    p_succession_plan_id           := null;
         p_object_version_number    := NULL;
         p_return_status            := hr_multi_message.get_return_status_disable;
         hr_utility.set_location (' Leaving:' || l_proc, 30);
      WHEN OTHERS
      THEN
         --
         -- When Multiple Message Detection is enabled catch
         -- any Application specific or other unexpected
         -- exceptions.  Adding appropriate details to the
         -- Multiple Message List.  Otherwise re-raise the
         -- error.
         --
         ROLLBACK TO create_succession_plan_swi;

         IF hr_multi_message.unexpected_error_add (l_proc)
         THEN
            hr_utility.set_location (' Leaving:' || l_proc, 40);
            RAISE;
         END IF;

    --
    -- Reset IN OUT and set OUT parameters
    --
--    p_succession_plan_id           := null;
         p_object_version_number    := NULL;
         p_return_status            := hr_multi_message.get_return_status_disable;
         hr_utility.set_location (' Leaving:' || l_proc, 50);
   END create_succession_plan;

-- ----------------------------------------------------------------------------
-- |------------------------< delete_succession_plan >------------------------|
-- ----------------------------------------------------------------------------
   PROCEDURE delete_succession_plan (
      p_validate                IN              NUMBER DEFAULT hr_api.g_false_num,
      p_succession_plan_id      IN              NUMBER,
      p_object_version_number   IN              NUMBER,
      p_return_status           OUT NOCOPY      VARCHAR2
   )
   IS
      --
      -- Variables for API Boolean parameters
      l_validate   BOOLEAN;
      --
      -- Variables for IN/OUT parameters
      --
      -- Other variables
      l_proc       VARCHAR2 (72) := g_package || 'delete_succession_plan';
   BEGIN
      hr_utility.set_location (' Entering:' || l_proc, 10);
      --
      -- Issue a savepoint
      --
      SAVEPOINT delete_succession_plan_swi;
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
      l_validate                 := hr_api.constant_to_boolean (p_constant_value => p_validate);
      --
      -- Register Surrogate ID or user key values
      --
      --
      -- Call API
      --
      per_succession_plan_api.delete_succession_plan
                                                (p_validate                   => l_validate,
                                                 p_succession_plan_id         => p_succession_plan_id,
                                                 p_object_version_number      => p_object_version_number
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
      p_return_status            := hr_multi_message.get_return_status_disable;
      hr_utility.set_location (' Leaving:' || l_proc, 20);
   --
   EXCEPTION
      WHEN hr_multi_message.error_message_exist
      THEN
         --
         -- Catch the Multiple Message List exception which
         -- indicates API processing has been aborted because
         -- at least one message exists in the list.
         --
         ROLLBACK TO delete_succession_plan_swi;
         --
         -- Reset IN OUT parameters and set OUT parameters
         --
         p_return_status            := hr_multi_message.get_return_status_disable;
         hr_utility.set_location (' Leaving:' || l_proc, 30);
      WHEN OTHERS
      THEN
         --
         -- When Multiple Message Detection is enabled catch
         -- any Application specific or other unexpected
         -- exceptions.  Adding appropriate details to the
         -- Multiple Message List.  Otherwise re-raise the
         -- error.
         --
         ROLLBACK TO delete_succession_plan_swi;

         IF hr_multi_message.unexpected_error_add (l_proc)
         THEN
            hr_utility.set_location (' Leaving:' || l_proc, 40);
            RAISE;
         END IF;

         --
         -- Reset IN OUT and set OUT parameters
         --
         p_return_status            := hr_multi_message.get_return_status_disable;
         hr_utility.set_location (' Leaving:' || l_proc, 50);
   END delete_succession_plan;

-- ----------------------------------------------------------------------------
-- |------------------------< update_succession_plan >------------------------|
-- ----------------------------------------------------------------------------
   PROCEDURE update_succession_plan (
      p_validate                  IN              NUMBER DEFAULT hr_api.g_false_num,
      p_succession_plan_id        IN              NUMBER,
      p_person_id                 IN              NUMBER DEFAULT hr_api.g_number,
      p_position_id               IN              NUMBER DEFAULT hr_api.g_number,
      p_business_group_id         IN              NUMBER DEFAULT hr_api.g_number,
      p_start_date                IN              DATE DEFAULT hr_api.g_date,
      p_time_scale                IN              VARCHAR2 DEFAULT hr_api.g_varchar2,
      p_end_date                  IN              DATE DEFAULT hr_api.g_date,
      p_available_for_promotion   IN              VARCHAR2 DEFAULT hr_api.g_varchar2,
      p_manager_comments          IN              VARCHAR2 DEFAULT hr_api.g_varchar2,
      p_attribute_category        IN              VARCHAR2 DEFAULT hr_api.g_varchar2,
      p_attribute1                IN              VARCHAR2 DEFAULT hr_api.g_varchar2,
      p_attribute2                IN              VARCHAR2 DEFAULT hr_api.g_varchar2,
      p_attribute3                IN              VARCHAR2 DEFAULT hr_api.g_varchar2,
      p_attribute4                IN              VARCHAR2 DEFAULT hr_api.g_varchar2,
      p_attribute5                IN              VARCHAR2 DEFAULT hr_api.g_varchar2,
      p_attribute6                IN              VARCHAR2 DEFAULT hr_api.g_varchar2,
      p_attribute7                IN              VARCHAR2 DEFAULT hr_api.g_varchar2,
      p_attribute8                IN              VARCHAR2 DEFAULT hr_api.g_varchar2,
      p_attribute9                IN              VARCHAR2 DEFAULT hr_api.g_varchar2,
      p_attribute10               IN              VARCHAR2 DEFAULT hr_api.g_varchar2,
      p_attribute11               IN              VARCHAR2 DEFAULT hr_api.g_varchar2,
      p_attribute12               IN              VARCHAR2 DEFAULT hr_api.g_varchar2,
      p_attribute13               IN              VARCHAR2 DEFAULT hr_api.g_varchar2,
      p_attribute14               IN              VARCHAR2 DEFAULT hr_api.g_varchar2,
      p_attribute15               IN              VARCHAR2 DEFAULT hr_api.g_varchar2,
      p_attribute16               IN              VARCHAR2 DEFAULT hr_api.g_varchar2,
      p_attribute17               IN              VARCHAR2 DEFAULT hr_api.g_varchar2,
      p_attribute18               IN              VARCHAR2 DEFAULT hr_api.g_varchar2,
      p_attribute19               IN              VARCHAR2 DEFAULT hr_api.g_varchar2,
      p_attribute20               IN              VARCHAR2 DEFAULT hr_api.g_varchar2,
      p_effective_date            IN              DATE,
      p_job_id                    IN              NUMBER DEFAULT hr_api.g_number,
      p_person_rank               IN              NUMBER DEFAULT hr_api.g_number,
      p_performance               IN              VARCHAR2 DEFAULT hr_api.g_varchar2,
      p_plan_status               IN              VARCHAR2 DEFAULT hr_api.g_varchar2,
      p_readiness_percentage      IN              NUMBER DEFAULT hr_api.g_number,
      p_successee_person_id       IN              NUMBER DEFAULT hr_api.g_number,
      p_object_version_number     IN OUT NOCOPY   NUMBER,
      p_return_status             OUT NOCOPY      VARCHAR2
   )
   IS
      --
      -- Variables for API Boolean parameters
      l_validate                BOOLEAN;
      --
      -- Variables for IN/OUT parameters
      l_object_version_number   NUMBER;
      --
      -- Other variables
      l_proc                    VARCHAR2 (72) := g_package || 'update_succession_plan';
   BEGIN
      hr_utility.set_location (' Entering:' || l_proc, 10);
      --
      -- Issue a savepoint
      --
      SAVEPOINT update_succession_plan_swi;
      --
      -- Initialise Multiple Message Detection
      --
      hr_multi_message.enable_message_list;
      --
      -- Remember IN OUT parameter IN values
      --
      l_object_version_number    := p_object_version_number;
      --
      -- Convert constant values to their corresponding boolean value
      --
      l_validate                 := hr_api.constant_to_boolean (p_constant_value => p_validate);
      --
      -- Register Surrogate ID or user key values
      --
      --
      -- Call API
      --
      per_succession_plan_api.update_succession_plan
                                           (p_validate                     => l_validate,
                                            p_succession_plan_id           => p_succession_plan_id,
                                            p_person_id                    => p_person_id,
                                            p_position_id                  => p_position_id,
                                            p_business_group_id            => p_business_group_id,
                                            p_start_date                   => p_start_date,
                                            p_time_scale                   => p_time_scale,
                                            p_end_date                     => p_end_date,
                                            p_available_for_promotion      => p_available_for_promotion,
                                            p_manager_comments             => p_manager_comments,
                                            p_attribute_category           => p_attribute_category,
                                            p_attribute1                   => p_attribute1,
                                            p_attribute2                   => p_attribute2,
                                            p_attribute3                   => p_attribute3,
                                            p_attribute4                   => p_attribute4,
                                            p_attribute5                   => p_attribute5,
                                            p_attribute6                   => p_attribute6,
                                            p_attribute7                   => p_attribute7,
                                            p_attribute8                   => p_attribute8,
                                            p_attribute9                   => p_attribute9,
                                            p_attribute10                  => p_attribute10,
                                            p_attribute11                  => p_attribute11,
                                            p_attribute12                  => p_attribute12,
                                            p_attribute13                  => p_attribute13,
                                            p_attribute14                  => p_attribute14,
                                            p_attribute15                  => p_attribute15,
                                            p_attribute16                  => p_attribute16,
                                            p_attribute17                  => p_attribute17,
                                            p_attribute18                  => p_attribute18,
                                            p_attribute19                  => p_attribute19,
                                            p_attribute20                  => p_attribute20,
                                            p_effective_date               => p_effective_date,
                                            p_job_id                       => p_job_id,
                                            p_person_rank                  => p_person_rank,
                                            p_performance                  => p_performance,
                                            p_plan_status                  => p_plan_status,
                                            p_readiness_percentage         => p_readiness_percentage,
                                            p_successee_person_id          => p_successee_person_id,
                                            p_object_version_number        => p_object_version_number
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
      p_return_status            := hr_multi_message.get_return_status_disable;
      hr_utility.set_location (' Leaving:' || l_proc, 20);
   --
   EXCEPTION
      WHEN hr_multi_message.error_message_exist
      THEN
         --
         -- Catch the Multiple Message List exception which
         -- indicates API processing has been aborted because
         -- at least one message exists in the list.
         --
         ROLLBACK TO update_succession_plan_swi;
         --
         -- Reset IN OUT parameters and set OUT parameters
         --
         p_object_version_number    := l_object_version_number;
         p_return_status            := hr_multi_message.get_return_status_disable;
         hr_utility.set_location (' Leaving:' || l_proc, 30);
      WHEN OTHERS
      THEN
         --
         -- When Multiple Message Detection is enabled catch
         -- any Application specific or other unexpected
         -- exceptions.  Adding appropriate details to the
         -- Multiple Message List.  Otherwise re-raise the
         -- error.
         --
         ROLLBACK TO update_succession_plan_swi;

         IF hr_multi_message.unexpected_error_add (l_proc)
         THEN
            hr_utility.set_location (' Leaving:' || l_proc, 40);
            RAISE;
         END IF;

         --
         -- Reset IN OUT and set OUT parameters
         --
         p_object_version_number    := l_object_version_number;
         p_return_status            := hr_multi_message.get_return_status_disable;
         hr_utility.set_location (' Leaving:' || l_proc, 50);
   END update_succession_plan;
END per_succession_plan_swi;

/
