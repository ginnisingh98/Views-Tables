--------------------------------------------------------
--  DDL for Package Body BEN_PERSON_LIFE_EVENT_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PERSON_LIFE_EVENT_SWI" As
/* $Header: bepilswi.pkb 120.0 2005/05/28 10:51:02 appldev noship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'ben_person_life_event_swi.';
--
-- ----------------------------------------------------------------------------
-- |----------------------< create_Person_Life_Event >----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_Person_Life_Event
  ( p_validate                     in     number    default hr_api.g_false_num
   ,p_per_in_ler_id                  out NOCOPY number
   ,p_per_in_ler_stat_cd             in  varchar2  default null
   ,p_prvs_stat_cd                   in  varchar2  default null
   ,p_lf_evt_ocrd_dt                 in  date      default null
   ,p_trgr_table_pk_id               in  number    default null --ABSE changes
   ,p_procd_dt                       out NOCOPY date
   ,p_strtd_dt                       out NOCOPY date
   ,p_voidd_dt                       out NOCOPY date
   ,p_bckt_dt                        in  date      default null
   ,p_clsd_dt                        in  date      default null
   ,p_ntfn_dt                        in  date      default null
   ,p_ptnl_ler_for_per_id            in  number    default null
   ,p_bckt_per_in_ler_id             in  number    default null
   ,p_ler_id                         in  number    default null
   ,p_person_id                      in  number    default null
   ,p_business_group_id              in  number    default null
   ,p_ASSIGNMENT_ID                  in  number    default null
   ,p_WS_MGR_ID                      in  number    default null
   ,p_GROUP_PL_ID                    in  number    default null
   ,p_MGR_OVRID_PERSON_ID            in  number    default null
   ,p_MGR_OVRID_DT                   in  date      default null
   ,p_pil_attribute_category         in  varchar2  default null
   ,p_pil_attribute1                 in  varchar2  default null
   ,p_pil_attribute2                 in  varchar2  default null
   ,p_pil_attribute3                 in  varchar2  default null
   ,p_pil_attribute4                 in  varchar2  default null
   ,p_pil_attribute5                 in  varchar2  default null
   ,p_pil_attribute6                 in  varchar2  default null
   ,p_pil_attribute7                 in  varchar2  default null
   ,p_pil_attribute8                 in  varchar2  default null
   ,p_pil_attribute9                 in  varchar2  default null
   ,p_pil_attribute10                in  varchar2  default null
   ,p_pil_attribute11                in  varchar2  default null
   ,p_pil_attribute12                in  varchar2  default null
   ,p_pil_attribute13                in  varchar2  default null
   ,p_pil_attribute14                in  varchar2  default null
   ,p_pil_attribute15                in  varchar2  default null
   ,p_pil_attribute16                in  varchar2  default null
   ,p_pil_attribute17                in  varchar2  default null
   ,p_pil_attribute18                in  varchar2  default null
   ,p_pil_attribute19                in  varchar2  default null
   ,p_pil_attribute20                in  varchar2  default null
   ,p_pil_attribute21                in  varchar2  default null
   ,p_pil_attribute22                in  varchar2  default null
   ,p_pil_attribute23                in  varchar2  default null
   ,p_pil_attribute24                in  varchar2  default null
   ,p_pil_attribute25                in  varchar2  default null
   ,p_pil_attribute26                in  varchar2  default null
   ,p_pil_attribute27                in  varchar2  default null
   ,p_pil_attribute28                in  varchar2  default null
   ,p_pil_attribute29                in  varchar2  default null
   ,p_pil_attribute30                in  varchar2  default null
   ,p_request_id                     in  number    default null
   ,p_program_application_id         in  number    default null
   ,p_program_id                     in  number    default null
   ,p_program_update_date            in  date      default null
   ,p_object_version_number          out NOCOPY number
   ,p_effective_date                 in  date
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'create_Person_Life_Event';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_Person_Life_Event_swi;
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
  ben_Person_Life_Event_api.create_Person_Life_Event
      ( p_validate                       =>  l_validate
   	,p_per_in_ler_id                =>  p_per_in_ler_id
       ,p_per_in_ler_stat_cd            =>  p_per_in_ler_stat_cd
       ,p_prvs_stat_cd                  =>  p_prvs_stat_cd
       ,p_lf_evt_ocrd_dt                =>  p_lf_evt_ocrd_dt
       ,p_trgr_table_pk_id              =>  p_trgr_table_pk_id
       ,p_procd_dt                      =>  p_procd_dt
       ,p_strtd_dt                      =>  p_strtd_dt
       ,p_voidd_dt                      =>  p_voidd_dt
       ,p_bckt_dt                       =>  p_bckt_dt
       ,p_clsd_dt                       =>  p_clsd_dt
       ,p_ntfn_dt                       =>  p_ntfn_dt
       ,p_ptnl_ler_for_per_id           =>  p_ptnl_ler_for_per_id
       ,p_bckt_per_in_ler_id            =>  p_bckt_per_in_ler_id
       ,p_ler_id                        =>  p_ler_id
       ,p_person_id                     =>  p_person_id
       ,p_business_group_id             =>  p_business_group_id
       ,p_ASSIGNMENT_ID                 =>  p_ASSIGNMENT_ID
       ,p_WS_MGR_ID                     =>  p_WS_MGR_ID
       ,p_GROUP_PL_ID                   =>  p_GROUP_PL_ID
       ,p_MGR_OVRID_PERSON_ID           =>  p_MGR_OVRID_PERSON_ID
       ,p_MGR_OVRID_DT                  =>  p_MGR_OVRID_DT
       ,p_pil_attribute_category        =>  p_pil_attribute_category
       ,p_pil_attribute1                =>  p_pil_attribute1
       ,p_pil_attribute2                =>  p_pil_attribute2
       ,p_pil_attribute3                =>  p_pil_attribute3
       ,p_pil_attribute4                =>  p_pil_attribute4
       ,p_pil_attribute5                =>  p_pil_attribute5
       ,p_pil_attribute6                =>  p_pil_attribute6
       ,p_pil_attribute7                =>  p_pil_attribute7
       ,p_pil_attribute8                =>  p_pil_attribute8
       ,p_pil_attribute9                =>  p_pil_attribute9
       ,p_pil_attribute10               =>  p_pil_attribute10
       ,p_pil_attribute11               =>  p_pil_attribute11
       ,p_pil_attribute12               =>  p_pil_attribute12
       ,p_pil_attribute13               =>  p_pil_attribute13
       ,p_pil_attribute14               =>  p_pil_attribute14
       ,p_pil_attribute15               =>  p_pil_attribute15
       ,p_pil_attribute16               =>  p_pil_attribute16
       ,p_pil_attribute17               =>  p_pil_attribute17
       ,p_pil_attribute18               =>  p_pil_attribute18
       ,p_pil_attribute19               =>  p_pil_attribute19
       ,p_pil_attribute20               =>  p_pil_attribute20
       ,p_pil_attribute21               =>  p_pil_attribute21
       ,p_pil_attribute22               =>  p_pil_attribute22
       ,p_pil_attribute23               =>  p_pil_attribute23
       ,p_pil_attribute24               =>  p_pil_attribute24
       ,p_pil_attribute25               =>  p_pil_attribute25
       ,p_pil_attribute26               =>  p_pil_attribute26
       ,p_pil_attribute27               =>  p_pil_attribute27
       ,p_pil_attribute28               =>  p_pil_attribute28
       ,p_pil_attribute29               =>  p_pil_attribute29
       ,p_pil_attribute30               =>  p_pil_attribute30
       ,p_request_id                    =>  p_request_id
       ,p_program_application_id        =>  p_program_application_id
       ,p_program_id                    =>  p_program_id
       ,p_program_update_date           =>  p_program_update_date
       ,p_object_version_number         =>  p_object_version_number
       ,p_effective_date            	=>  p_effective_date);

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
    rollback to create_Person_Life_Event_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
   p_per_in_ler_id       := null;
      p_object_version_number        := null;
      p_procd_dt     := null;
      p_strtd_dt     := null;
    p_voidd_dt     := null;
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
    rollback to create_Person_Life_Event_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_per_in_ler_id       := null;
    p_object_version_number        := null;
    p_procd_dt     := null;
    p_strtd_dt     := null;
    p_voidd_dt     := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end create_Person_Life_Event;
-- ----------------------------------------------------------------------------
-- |----------------------< delete_Person_Life_Event >----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_Person_Life_Event
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_per_in_ler_id                  in  number
  ,p_object_version_number          in out NOCOPY number
  ,p_effective_date                 in  date
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
  l_proc    varchar2(72) := g_package ||'delete_Person_Life_Event';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_Person_Life_Event_swi;
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
  ben_Person_Life_Event_api.delete_Person_Life_Event
    (p_validate                     => l_validate
    ,p_per_in_ler_id       => p_per_in_ler_id
    ,p_object_version_number        => p_object_version_number
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
    rollback to delete_Person_Life_Event_swi;
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
    rollback to delete_Person_Life_Event_swi;
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
end delete_Person_Life_Event;
-- ----------------------------------------------------------------------------
-- |----------------------------------< lck >---------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE lck
  (p_per_in_ler_id       in     number
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'lck';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint lck_swi;
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
  --
  -- Register Surrogate ID or user key values
  --
  --
  -- Call API
  --
  ben_Person_Life_Event_api.lck
    (p_per_in_ler_id       => p_per_in_ler_id
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
    rollback to lck_swi;
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
    rollback to lck_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end lck;
-- ----------------------------------------------------------------------------
-- |----------------------< update_Person_Life_Event >----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_Person_Life_Event
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_per_in_ler_id                  in  number
    ,p_per_in_ler_stat_cd             in  varchar2  default hr_api.g_varchar2
    ,p_prvs_stat_cd                   in  varchar2  default hr_api.g_varchar2
    ,p_lf_evt_ocrd_dt                 in  date      default hr_api.g_date
    ,p_trgr_table_pk_id               in  number    default hr_api.g_number --ABSE changes
    ,p_procd_dt                       out NOCOPY date
    ,p_strtd_dt                       out NOCOPY date
    ,p_voidd_dt                       out NOCOPY date
    ,p_bckt_dt                        in  date      default hr_api.g_date
    ,p_clsd_dt                        in  date      default hr_api.g_date
    ,p_ntfn_dt                        in  date      default hr_api.g_date
    ,p_ptnl_ler_for_per_id            in  number    default hr_api.g_number
    ,p_bckt_per_in_ler_id             in  number    default hr_api.g_number
    ,p_ler_id                         in  number    default hr_api.g_number
    ,p_person_id                      in  number    default hr_api.g_number
    ,p_business_group_id              in  number    default hr_api.g_number
    ,p_ASSIGNMENT_ID                  in  number    default hr_api.g_number
    ,p_WS_MGR_ID                      in  number    default hr_api.g_number
    ,p_GROUP_PL_ID                    in  number    default hr_api.g_number
    ,p_MGR_OVRID_PERSON_ID            in  number    default hr_api.g_number
    ,p_MGR_OVRID_DT                   in  date      default hr_api.g_date
    ,p_pil_attribute_category         in  varchar2  default hr_api.g_varchar2
    ,p_pil_attribute1                 in  varchar2  default hr_api.g_varchar2
    ,p_pil_attribute2                 in  varchar2  default hr_api.g_varchar2
    ,p_pil_attribute3                 in  varchar2  default hr_api.g_varchar2
    ,p_pil_attribute4                 in  varchar2  default hr_api.g_varchar2
    ,p_pil_attribute5                 in  varchar2  default hr_api.g_varchar2
    ,p_pil_attribute6                 in  varchar2  default hr_api.g_varchar2
    ,p_pil_attribute7                 in  varchar2  default hr_api.g_varchar2
    ,p_pil_attribute8                 in  varchar2  default hr_api.g_varchar2
    ,p_pil_attribute9                 in  varchar2  default hr_api.g_varchar2
    ,p_pil_attribute10                in  varchar2  default hr_api.g_varchar2
    ,p_pil_attribute11                in  varchar2  default hr_api.g_varchar2
    ,p_pil_attribute12                in  varchar2  default hr_api.g_varchar2
    ,p_pil_attribute13                in  varchar2  default hr_api.g_varchar2
    ,p_pil_attribute14                in  varchar2  default hr_api.g_varchar2
    ,p_pil_attribute15                in  varchar2  default hr_api.g_varchar2
    ,p_pil_attribute16                in  varchar2  default hr_api.g_varchar2
    ,p_pil_attribute17                in  varchar2  default hr_api.g_varchar2
    ,p_pil_attribute18                in  varchar2  default hr_api.g_varchar2
    ,p_pil_attribute19                in  varchar2  default hr_api.g_varchar2
    ,p_pil_attribute20                in  varchar2  default hr_api.g_varchar2
    ,p_pil_attribute21                in  varchar2  default hr_api.g_varchar2
    ,p_pil_attribute22                in  varchar2  default hr_api.g_varchar2
    ,p_pil_attribute23                in  varchar2  default hr_api.g_varchar2
    ,p_pil_attribute24                in  varchar2  default hr_api.g_varchar2
    ,p_pil_attribute25                in  varchar2  default hr_api.g_varchar2
    ,p_pil_attribute26                in  varchar2  default hr_api.g_varchar2
    ,p_pil_attribute27                in  varchar2  default hr_api.g_varchar2
    ,p_pil_attribute28                in  varchar2  default hr_api.g_varchar2
    ,p_pil_attribute29                in  varchar2  default hr_api.g_varchar2
    ,p_pil_attribute30                in  varchar2  default hr_api.g_varchar2
    ,p_request_id                     in  number    default hr_api.g_number
    ,p_program_application_id         in  number    default hr_api.g_number
    ,p_program_id                     in  number    default hr_api.g_number
    ,p_program_update_date            in  date      default hr_api.g_date
    ,p_object_version_number          in out NOCOPY number
  ,p_effective_date                 in  date
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
  l_proc    varchar2(72) := g_package ||'update_Person_Life_Event';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_Person_Life_Event_swi;
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
  ben_Person_Life_Event_api.update_Person_Life_Event
    (p_validate                     => l_validate
    ,p_per_in_ler_id                  =>  p_per_in_ler_id
      ,p_per_in_ler_stat_cd             =>  p_per_in_ler_stat_cd
      ,p_prvs_stat_cd                   =>  p_prvs_stat_cd
      ,p_lf_evt_ocrd_dt                 =>  p_lf_evt_ocrd_dt
      ,p_trgr_table_pk_id               =>  p_trgr_table_pk_id --ABSE changes
      ,p_procd_dt                       =>  p_procd_dt
      ,p_strtd_dt                       =>  p_strtd_dt
      ,p_voidd_dt                       =>  p_voidd_dt
      ,p_bckt_dt                        =>  p_bckt_dt
      ,p_clsd_dt                        =>  p_clsd_dt
      ,p_ntfn_dt                        =>  p_ntfn_dt
      ,p_ptnl_ler_for_per_id            =>  p_ptnl_ler_for_per_id
      ,p_bckt_per_in_ler_id             =>  p_bckt_per_in_ler_id
      ,p_ler_id                         =>  p_ler_id
      ,p_person_id                      =>  p_person_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_ASSIGNMENT_ID                  =>  p_ASSIGNMENT_ID
      ,p_WS_MGR_ID                      =>  p_WS_MGR_ID
      ,p_GROUP_PL_ID                    =>  p_GROUP_PL_ID
      ,p_MGR_OVRID_PERSON_ID            =>  p_MGR_OVRID_PERSON_ID
      ,p_MGR_OVRID_DT                   =>  p_MGR_OVRID_DT
      ,p_pil_attribute_category         =>  p_pil_attribute_category
      ,p_pil_attribute1                 =>  p_pil_attribute1
      ,p_pil_attribute2                 =>  p_pil_attribute2
      ,p_pil_attribute3                 =>  p_pil_attribute3
      ,p_pil_attribute4                 =>  p_pil_attribute4
      ,p_pil_attribute5                 =>  p_pil_attribute5
      ,p_pil_attribute6                 =>  p_pil_attribute6
      ,p_pil_attribute7                 =>  p_pil_attribute7
      ,p_pil_attribute8                 =>  p_pil_attribute8
      ,p_pil_attribute9                 =>  p_pil_attribute9
      ,p_pil_attribute10                =>  p_pil_attribute10
      ,p_pil_attribute11                =>  p_pil_attribute11
      ,p_pil_attribute12                =>  p_pil_attribute12
      ,p_pil_attribute13                =>  p_pil_attribute13
      ,p_pil_attribute14                =>  p_pil_attribute14
      ,p_pil_attribute15                =>  p_pil_attribute15
      ,p_pil_attribute16                =>  p_pil_attribute16
      ,p_pil_attribute17                =>  p_pil_attribute17
      ,p_pil_attribute18                =>  p_pil_attribute18
      ,p_pil_attribute19                =>  p_pil_attribute19
      ,p_pil_attribute20                =>  p_pil_attribute20
      ,p_pil_attribute21                =>  p_pil_attribute21
      ,p_pil_attribute22                =>  p_pil_attribute22
      ,p_pil_attribute23                =>  p_pil_attribute23
      ,p_pil_attribute24                =>  p_pil_attribute24
      ,p_pil_attribute25                =>  p_pil_attribute25
      ,p_pil_attribute26                =>  p_pil_attribute26
      ,p_pil_attribute27                =>  p_pil_attribute27
      ,p_pil_attribute28                =>  p_pil_attribute28
      ,p_pil_attribute29                =>  p_pil_attribute29
      ,p_pil_attribute30                =>  p_pil_attribute30
      ,p_request_id                     =>  p_request_id
      ,p_program_application_id         =>  p_program_application_id
      ,p_program_id                     =>  p_program_id
      ,p_program_update_date            =>  p_program_update_date
      ,p_object_version_number          =>  p_object_version_number
      ,p_effective_date                 =>  p_effective_date
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
    rollback to update_Person_Life_Event_swi;
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
    rollback to update_Person_Life_Event_swi;
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
end update_Person_Life_Event;
end ben_person_life_event_swi;

/
