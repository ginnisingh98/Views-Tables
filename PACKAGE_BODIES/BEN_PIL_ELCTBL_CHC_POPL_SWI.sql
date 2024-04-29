--------------------------------------------------------
--  DDL for Package Body BEN_PIL_ELCTBL_CHC_POPL_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PIL_ELCTBL_CHC_POPL_SWI" As
/* $Header: bepelswi.pkb 115.0 2003/03/10 15:20:42 aupadhya noship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'ben_pil_elctbl_chc_popl_swi.';
--
-- ----------------------------------------------------------------------------
-- |----------------------< create_pil_elctbl_chc_popl >----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_pil_elctbl_chc_popl
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_pil_elctbl_chc_popl_id          out nocopy number
  ,p_dflt_enrt_dt                 in     date      default null
  ,p_dflt_asnd_dt                 in     date      default null
  ,p_elcns_made_dt                in     date      default null
  ,p_cls_enrt_dt_to_use_cd        in     varchar2  default null
  ,p_enrt_typ_cycl_cd             in     varchar2  default null
  ,p_enrt_perd_end_dt             in     date      default null
  ,p_enrt_perd_strt_dt            in     date      default null
  ,p_procg_end_dt                 in     date      default null
  ,p_pil_elctbl_popl_stat_cd      in     varchar2  default null
  ,p_acty_ref_perd_cd             in     varchar2  default null
  ,p_uom                          in     varchar2  default null
  ,p_comments                     in     varchar2  default null
  ,p_mgr_ovrid_dt                 in     date      default null
  ,p_ws_mgr_id                    in     number    default null
  ,p_mgr_ovrid_person_id          in     number    default null
  ,p_assignment_id                in     number    default null
  ,p_bdgt_acc_cd                  in     varchar2  default null
  ,p_pop_cd                       in     varchar2  default null
  ,p_bdgt_due_dt                  in     date      default null
  ,p_bdgt_export_flag             in     varchar2  default null
  ,p_bdgt_iss_dt                  in     date      default null
  ,p_bdgt_stat_cd                 in     varchar2  default null
  ,p_ws_acc_cd                    in     varchar2  default null
  ,p_ws_due_dt                    in     date      default null
  ,p_ws_export_flag               in     varchar2  default null
  ,p_ws_iss_dt                    in     date      default null
  ,p_ws_stat_cd                   in     varchar2  default null
  ,p_auto_asnd_dt                 in     date      default null
  ,p_cbr_elig_perd_strt_dt        in     date      default null
  ,p_cbr_elig_perd_end_dt         in     date      default null
  ,p_lee_rsn_id                   in     number    default null
  ,p_enrt_perd_id                 in     number    default null
  ,p_per_in_ler_id                in     number    default null
  ,p_pgm_id                       in     number    default null
  ,p_pl_id                        in     number    default null
  ,p_business_group_id            in     number    default null
  ,p_pel_attribute_category       in     varchar2  default null
  ,p_pel_attribute1               in     varchar2  default null
  ,p_pel_attribute2               in     varchar2  default null
  ,p_pel_attribute3               in     varchar2  default null
  ,p_pel_attribute4               in     varchar2  default null
  ,p_pel_attribute5               in     varchar2  default null
  ,p_pel_attribute6               in     varchar2  default null
  ,p_pel_attribute7               in     varchar2  default null
  ,p_pel_attribute8               in     varchar2  default null
  ,p_pel_attribute9               in     varchar2  default null
  ,p_pel_attribute10              in     varchar2  default null
  ,p_pel_attribute11              in     varchar2  default null
  ,p_pel_attribute12              in     varchar2  default null
  ,p_pel_attribute13              in     varchar2  default null
  ,p_pel_attribute14              in     varchar2  default null
  ,p_pel_attribute15              in     varchar2  default null
  ,p_pel_attribute16              in     varchar2  default null
  ,p_pel_attribute17              in     varchar2  default null
  ,p_pel_attribute18              in     varchar2  default null
  ,p_pel_attribute19              in     varchar2  default null
  ,p_pel_attribute20              in     varchar2  default null
  ,p_pel_attribute21              in     varchar2  default null
  ,p_pel_attribute22              in     varchar2  default null
  ,p_pel_attribute23              in     varchar2  default null
  ,p_pel_attribute24              in     varchar2  default null
  ,p_pel_attribute25              in     varchar2  default null
  ,p_pel_attribute26              in     varchar2  default null
  ,p_pel_attribute27              in     varchar2  default null
  ,p_pel_attribute28              in     varchar2  default null
  ,p_pel_attribute29              in     varchar2  default null
  ,p_pel_attribute30              in     varchar2  default null
  ,p_request_id                   in     number    default null
  ,p_program_application_id       in     number    default null
  ,p_program_id                   in     number    default null
  ,p_program_update_date          in     date      default null
  ,p_object_version_number           out nocopy number
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
  l_proc    varchar2(72) := g_package ||'create_pil_elctbl_chc_popl';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_pil_elctbl_chc_popl_swi;
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
  ben_pil_elctbl_chc_popl_api.create_pil_elctbl_chc_popl
    (p_validate                     => l_validate
    ,p_pil_elctbl_chc_popl_id       => p_pil_elctbl_chc_popl_id
    ,p_dflt_enrt_dt                 => p_dflt_enrt_dt
    ,p_dflt_asnd_dt                 => p_dflt_asnd_dt
    ,p_elcns_made_dt                => p_elcns_made_dt
    ,p_cls_enrt_dt_to_use_cd        => p_cls_enrt_dt_to_use_cd
    ,p_enrt_typ_cycl_cd             => p_enrt_typ_cycl_cd
    ,p_enrt_perd_end_dt             => p_enrt_perd_end_dt
    ,p_enrt_perd_strt_dt            => p_enrt_perd_strt_dt
    ,p_procg_end_dt                 => p_procg_end_dt
    ,p_pil_elctbl_popl_stat_cd      => p_pil_elctbl_popl_stat_cd
    ,p_acty_ref_perd_cd             => p_acty_ref_perd_cd
    ,p_uom                          => p_uom
    ,p_comments                     => p_comments
    ,p_mgr_ovrid_dt                 => p_mgr_ovrid_dt
    ,p_ws_mgr_id                    => p_ws_mgr_id
    ,p_mgr_ovrid_person_id          => p_mgr_ovrid_person_id
    ,p_assignment_id                => p_assignment_id
    ,p_bdgt_acc_cd                  => p_bdgt_acc_cd
    ,p_pop_cd                       => p_pop_cd
    ,p_bdgt_due_dt                  => p_bdgt_due_dt
    ,p_bdgt_export_flag             => p_bdgt_export_flag
    ,p_bdgt_iss_dt                  => p_bdgt_iss_dt
    ,p_bdgt_stat_cd                 => p_bdgt_stat_cd
    ,p_ws_acc_cd                    => p_ws_acc_cd
    ,p_ws_due_dt                    => p_ws_due_dt
    ,p_ws_export_flag               => p_ws_export_flag
    ,p_ws_iss_dt                    => p_ws_iss_dt
    ,p_ws_stat_cd                   => p_ws_stat_cd
    ,p_auto_asnd_dt                 => p_auto_asnd_dt
    ,p_cbr_elig_perd_strt_dt        => p_cbr_elig_perd_strt_dt
    ,p_cbr_elig_perd_end_dt         => p_cbr_elig_perd_end_dt
    ,p_lee_rsn_id                   => p_lee_rsn_id
    ,p_enrt_perd_id                 => p_enrt_perd_id
    ,p_per_in_ler_id                => p_per_in_ler_id
    ,p_pgm_id                       => p_pgm_id
    ,p_pl_id                        => p_pl_id
    ,p_business_group_id            => p_business_group_id
    ,p_pel_attribute_category       => p_pel_attribute_category
    ,p_pel_attribute1               => p_pel_attribute1
    ,p_pel_attribute2               => p_pel_attribute2
    ,p_pel_attribute3               => p_pel_attribute3
    ,p_pel_attribute4               => p_pel_attribute4
    ,p_pel_attribute5               => p_pel_attribute5
    ,p_pel_attribute6               => p_pel_attribute6
    ,p_pel_attribute7               => p_pel_attribute7
    ,p_pel_attribute8               => p_pel_attribute8
    ,p_pel_attribute9               => p_pel_attribute9
    ,p_pel_attribute10              => p_pel_attribute10
    ,p_pel_attribute11              => p_pel_attribute11
    ,p_pel_attribute12              => p_pel_attribute12
    ,p_pel_attribute13              => p_pel_attribute13
    ,p_pel_attribute14              => p_pel_attribute14
    ,p_pel_attribute15              => p_pel_attribute15
    ,p_pel_attribute16              => p_pel_attribute16
    ,p_pel_attribute17              => p_pel_attribute17
    ,p_pel_attribute18              => p_pel_attribute18
    ,p_pel_attribute19              => p_pel_attribute19
    ,p_pel_attribute20              => p_pel_attribute20
    ,p_pel_attribute21              => p_pel_attribute21
    ,p_pel_attribute22              => p_pel_attribute22
    ,p_pel_attribute23              => p_pel_attribute23
    ,p_pel_attribute24              => p_pel_attribute24
    ,p_pel_attribute25              => p_pel_attribute25
    ,p_pel_attribute26              => p_pel_attribute26
    ,p_pel_attribute27              => p_pel_attribute27
    ,p_pel_attribute28              => p_pel_attribute28
    ,p_pel_attribute29              => p_pel_attribute29
    ,p_pel_attribute30              => p_pel_attribute30
    ,p_request_id                   => p_request_id
    ,p_program_application_id       => p_program_application_id
    ,p_program_id                   => p_program_id
    ,p_program_update_date          => p_program_update_date
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
    rollback to create_pil_elctbl_chc_popl_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_pil_elctbl_chc_popl_id       := null;
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
    rollback to create_pil_elctbl_chc_popl_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_pil_elctbl_chc_popl_id       := null;
    p_object_version_number        := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end create_pil_elctbl_chc_popl;
-- ----------------------------------------------------------------------------
-- |----------------------< delete_pil_elctbl_chc_popl >----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_pil_elctbl_chc_popl
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_pil_elctbl_chc_popl_id       in     number
  ,p_object_version_number        in out nocopy number
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
  l_proc    varchar2(72) := g_package ||'delete_pil_elctbl_chc_popl';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_pil_elctbl_chc_popl_swi;
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
  ben_pil_elctbl_chc_popl_api.delete_pil_elctbl_chc_popl
    (p_validate                     => l_validate
    ,p_pil_elctbl_chc_popl_id       => p_pil_elctbl_chc_popl_id
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
    rollback to delete_pil_elctbl_chc_popl_swi;
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
    rollback to delete_pil_elctbl_chc_popl_swi;
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
end delete_pil_elctbl_chc_popl;
-- ----------------------------------------------------------------------------
-- |----------------------------------< lck >---------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE lck
  (p_pil_elctbl_chc_popl_id       in     number
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
  ben_pil_elctbl_chc_popl_api.lck
    (p_pil_elctbl_chc_popl_id       => p_pil_elctbl_chc_popl_id
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
-- |----------------------< update_pil_elctbl_chc_popl >----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_pil_elctbl_chc_popl
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_pil_elctbl_chc_popl_id       in     number
  ,p_dflt_enrt_dt                 in     date      default hr_api.g_date
  ,p_dflt_asnd_dt                 in     date      default hr_api.g_date
  ,p_elcns_made_dt                in     date      default hr_api.g_date
  ,p_cls_enrt_dt_to_use_cd        in     varchar2  default hr_api.g_varchar2
  ,p_enrt_typ_cycl_cd             in     varchar2  default hr_api.g_varchar2
  ,p_enrt_perd_end_dt             in     date      default hr_api.g_date
  ,p_enrt_perd_strt_dt            in     date      default hr_api.g_date
  ,p_procg_end_dt                 in     date      default hr_api.g_date
  ,p_pil_elctbl_popl_stat_cd      in     varchar2  default hr_api.g_varchar2
  ,p_acty_ref_perd_cd             in     varchar2  default hr_api.g_varchar2
  ,p_uom                          in     varchar2  default hr_api.g_varchar2
  ,p_comments                     in     varchar2  default hr_api.g_varchar2
  ,p_mgr_ovrid_dt                 in     date      default hr_api.g_date
  ,p_ws_mgr_id                    in     number    default hr_api.g_number
  ,p_mgr_ovrid_person_id          in     number    default hr_api.g_number
  ,p_assignment_id                in     number    default hr_api.g_number
  ,p_bdgt_acc_cd                  in     varchar2  default hr_api.g_varchar2
  ,p_pop_cd                       in     varchar2  default hr_api.g_varchar2
  ,p_bdgt_due_dt                  in     date      default hr_api.g_date
  ,p_bdgt_export_flag             in     varchar2  default hr_api.g_varchar2
  ,p_bdgt_iss_dt                  in     date      default hr_api.g_date
  ,p_bdgt_stat_cd                 in     varchar2  default hr_api.g_varchar2
  ,p_ws_acc_cd                    in     varchar2  default hr_api.g_varchar2
  ,p_ws_due_dt                    in     date      default hr_api.g_date
  ,p_ws_export_flag               in     varchar2  default hr_api.g_varchar2
  ,p_ws_iss_dt                    in     date      default hr_api.g_date
  ,p_ws_stat_cd                   in     varchar2  default hr_api.g_varchar2
  ,p_auto_asnd_dt                 in     date      default hr_api.g_date
  ,p_cbr_elig_perd_strt_dt        in     date      default hr_api.g_date
  ,p_cbr_elig_perd_end_dt         in     date      default hr_api.g_date
  ,p_lee_rsn_id                   in     number    default hr_api.g_number
  ,p_enrt_perd_id                 in     number    default hr_api.g_number
  ,p_per_in_ler_id                in     number    default hr_api.g_number
  ,p_pgm_id                       in     number    default hr_api.g_number
  ,p_pl_id                        in     number    default hr_api.g_number
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_pel_attribute_category       in     varchar2  default hr_api.g_varchar2
  ,p_pel_attribute1               in     varchar2  default hr_api.g_varchar2
  ,p_pel_attribute2               in     varchar2  default hr_api.g_varchar2
  ,p_pel_attribute3               in     varchar2  default hr_api.g_varchar2
  ,p_pel_attribute4               in     varchar2  default hr_api.g_varchar2
  ,p_pel_attribute5               in     varchar2  default hr_api.g_varchar2
  ,p_pel_attribute6               in     varchar2  default hr_api.g_varchar2
  ,p_pel_attribute7               in     varchar2  default hr_api.g_varchar2
  ,p_pel_attribute8               in     varchar2  default hr_api.g_varchar2
  ,p_pel_attribute9               in     varchar2  default hr_api.g_varchar2
  ,p_pel_attribute10              in     varchar2  default hr_api.g_varchar2
  ,p_pel_attribute11              in     varchar2  default hr_api.g_varchar2
  ,p_pel_attribute12              in     varchar2  default hr_api.g_varchar2
  ,p_pel_attribute13              in     varchar2  default hr_api.g_varchar2
  ,p_pel_attribute14              in     varchar2  default hr_api.g_varchar2
  ,p_pel_attribute15              in     varchar2  default hr_api.g_varchar2
  ,p_pel_attribute16              in     varchar2  default hr_api.g_varchar2
  ,p_pel_attribute17              in     varchar2  default hr_api.g_varchar2
  ,p_pel_attribute18              in     varchar2  default hr_api.g_varchar2
  ,p_pel_attribute19              in     varchar2  default hr_api.g_varchar2
  ,p_pel_attribute20              in     varchar2  default hr_api.g_varchar2
  ,p_pel_attribute21              in     varchar2  default hr_api.g_varchar2
  ,p_pel_attribute22              in     varchar2  default hr_api.g_varchar2
  ,p_pel_attribute23              in     varchar2  default hr_api.g_varchar2
  ,p_pel_attribute24              in     varchar2  default hr_api.g_varchar2
  ,p_pel_attribute25              in     varchar2  default hr_api.g_varchar2
  ,p_pel_attribute26              in     varchar2  default hr_api.g_varchar2
  ,p_pel_attribute27              in     varchar2  default hr_api.g_varchar2
  ,p_pel_attribute28              in     varchar2  default hr_api.g_varchar2
  ,p_pel_attribute29              in     varchar2  default hr_api.g_varchar2
  ,p_pel_attribute30              in     varchar2  default hr_api.g_varchar2
  ,p_request_id                   in     number    default hr_api.g_number
  ,p_program_application_id       in     number    default hr_api.g_number
  ,p_program_id                   in     number    default hr_api.g_number
  ,p_program_update_date          in     date      default hr_api.g_date
  ,p_object_version_number        in out nocopy number
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
  l_proc    varchar2(72) := g_package ||'update_pil_elctbl_chc_popl';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_pil_elctbl_chc_popl_swi;
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
  ben_pil_elctbl_chc_popl_api.update_pil_elctbl_chc_popl
    (p_validate                     => l_validate
    ,p_pil_elctbl_chc_popl_id       => p_pil_elctbl_chc_popl_id
    ,p_dflt_enrt_dt                 => p_dflt_enrt_dt
    ,p_dflt_asnd_dt                 => p_dflt_asnd_dt
    ,p_elcns_made_dt                => p_elcns_made_dt
    ,p_cls_enrt_dt_to_use_cd        => p_cls_enrt_dt_to_use_cd
    ,p_enrt_typ_cycl_cd             => p_enrt_typ_cycl_cd
    ,p_enrt_perd_end_dt             => p_enrt_perd_end_dt
    ,p_enrt_perd_strt_dt            => p_enrt_perd_strt_dt
    ,p_procg_end_dt                 => p_procg_end_dt
    ,p_pil_elctbl_popl_stat_cd      => p_pil_elctbl_popl_stat_cd
    ,p_acty_ref_perd_cd             => p_acty_ref_perd_cd
    ,p_uom                          => p_uom
    ,p_comments                     => p_comments
    ,p_mgr_ovrid_dt                 => p_mgr_ovrid_dt
    ,p_ws_mgr_id                    => p_ws_mgr_id
    ,p_mgr_ovrid_person_id          => p_mgr_ovrid_person_id
    ,p_assignment_id                => p_assignment_id
    ,p_bdgt_acc_cd                  => p_bdgt_acc_cd
    ,p_pop_cd                       => p_pop_cd
    ,p_bdgt_due_dt                  => p_bdgt_due_dt
    ,p_bdgt_export_flag             => p_bdgt_export_flag
    ,p_bdgt_iss_dt                  => p_bdgt_iss_dt
    ,p_bdgt_stat_cd                 => p_bdgt_stat_cd
    ,p_ws_acc_cd                    => p_ws_acc_cd
    ,p_ws_due_dt                    => p_ws_due_dt
    ,p_ws_export_flag               => p_ws_export_flag
    ,p_ws_iss_dt                    => p_ws_iss_dt
    ,p_ws_stat_cd                   => p_ws_stat_cd
    ,p_auto_asnd_dt                 => p_auto_asnd_dt
    ,p_cbr_elig_perd_strt_dt        => p_cbr_elig_perd_strt_dt
    ,p_cbr_elig_perd_end_dt         => p_cbr_elig_perd_end_dt
    ,p_lee_rsn_id                   => p_lee_rsn_id
    ,p_enrt_perd_id                 => p_enrt_perd_id
    ,p_per_in_ler_id                => p_per_in_ler_id
    ,p_pgm_id                       => p_pgm_id
    ,p_pl_id                        => p_pl_id
    ,p_business_group_id            => p_business_group_id
    ,p_pel_attribute_category       => p_pel_attribute_category
    ,p_pel_attribute1               => p_pel_attribute1
    ,p_pel_attribute2               => p_pel_attribute2
    ,p_pel_attribute3               => p_pel_attribute3
    ,p_pel_attribute4               => p_pel_attribute4
    ,p_pel_attribute5               => p_pel_attribute5
    ,p_pel_attribute6               => p_pel_attribute6
    ,p_pel_attribute7               => p_pel_attribute7
    ,p_pel_attribute8               => p_pel_attribute8
    ,p_pel_attribute9               => p_pel_attribute9
    ,p_pel_attribute10              => p_pel_attribute10
    ,p_pel_attribute11              => p_pel_attribute11
    ,p_pel_attribute12              => p_pel_attribute12
    ,p_pel_attribute13              => p_pel_attribute13
    ,p_pel_attribute14              => p_pel_attribute14
    ,p_pel_attribute15              => p_pel_attribute15
    ,p_pel_attribute16              => p_pel_attribute16
    ,p_pel_attribute17              => p_pel_attribute17
    ,p_pel_attribute18              => p_pel_attribute18
    ,p_pel_attribute19              => p_pel_attribute19
    ,p_pel_attribute20              => p_pel_attribute20
    ,p_pel_attribute21              => p_pel_attribute21
    ,p_pel_attribute22              => p_pel_attribute22
    ,p_pel_attribute23              => p_pel_attribute23
    ,p_pel_attribute24              => p_pel_attribute24
    ,p_pel_attribute25              => p_pel_attribute25
    ,p_pel_attribute26              => p_pel_attribute26
    ,p_pel_attribute27              => p_pel_attribute27
    ,p_pel_attribute28              => p_pel_attribute28
    ,p_pel_attribute29              => p_pel_attribute29
    ,p_pel_attribute30              => p_pel_attribute30
    ,p_request_id                   => p_request_id
    ,p_program_application_id       => p_program_application_id
    ,p_program_id                   => p_program_id
    ,p_program_update_date          => p_program_update_date
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
    rollback to update_pil_elctbl_chc_popl_swi;
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
    rollback to update_pil_elctbl_chc_popl_swi;
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
end update_pil_elctbl_chc_popl;
end ben_pil_elctbl_chc_popl_swi;

/
