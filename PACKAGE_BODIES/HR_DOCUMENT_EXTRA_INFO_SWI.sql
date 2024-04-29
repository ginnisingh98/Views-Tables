--------------------------------------------------------
--  DDL for Package Body HR_DOCUMENT_EXTRA_INFO_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_DOCUMENT_EXTRA_INFO_SWI" As
/* $Header: hrdeiswi.pkb 120.0.12010000.3 2010/06/08 20:07:48 tkghosh ship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'hr_document_extra_info_swi.';
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_doc_extra_info >------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_doc_extra_info
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_person_id                    in     number
  ,p_document_type_id             in     number
  ,p_date_from                    in     date
  ,p_date_to                      in     date  default null
  ,p_document_number              in     varchar2  default null
  ,p_issued_by                    in     varchar2  default null
  ,p_issued_at                    in     varchar2  default null
  ,p_issued_date                  in     date      default null
  ,p_issuing_authority            in     varchar2  default null
  ,p_verified_by                  in     number    default null
  ,p_verified_date                in     date      default null
  ,p_related_object_name          in     varchar2  default null
  ,p_related_object_id_col        in     varchar2  default null
  ,p_related_object_id            in     number    default null
  ,p_dei_attribute_category       in     varchar2  default null
  ,p_dei_attribute1               in     varchar2  default null
  ,p_dei_attribute2               in     varchar2  default null
  ,p_dei_attribute3               in     varchar2  default null
  ,p_dei_attribute4               in     varchar2  default null
  ,p_dei_attribute5               in     varchar2  default null
  ,p_dei_attribute6               in     varchar2  default null
  ,p_dei_attribute7               in     varchar2  default null
  ,p_dei_attribute8               in     varchar2  default null
  ,p_dei_attribute9               in     varchar2  default null
  ,p_dei_attribute10              in     varchar2  default null
  ,p_dei_attribute11              in     varchar2  default null
  ,p_dei_attribute12              in     varchar2  default null
  ,p_dei_attribute13              in     varchar2  default null
  ,p_dei_attribute14              in     varchar2  default null
  ,p_dei_attribute15              in     varchar2  default null
  ,p_dei_attribute16              in     varchar2  default null
  ,p_dei_attribute17              in     varchar2  default null
  ,p_dei_attribute18              in     varchar2  default null
  ,p_dei_attribute19              in     varchar2  default null
  ,p_dei_attribute20              in     varchar2  default null
  ,p_dei_attribute21              in     varchar2  default null
  ,p_dei_attribute22              in     varchar2  default null
  ,p_dei_attribute23              in     varchar2  default null
  ,p_dei_attribute24              in     varchar2  default null
  ,p_dei_attribute25              in     varchar2  default null
  ,p_dei_attribute26              in     varchar2  default null
  ,p_dei_attribute27              in     varchar2  default null
  ,p_dei_attribute28              in     varchar2  default null
  ,p_dei_attribute29              in     varchar2  default null
  ,p_dei_attribute30              in     varchar2  default null
  ,p_dei_information_category     in     varchar2  default null
  ,p_dei_information1             in     varchar2  default null
  ,p_dei_information2             in     varchar2  default null
  ,p_dei_information3             in     varchar2  default null
  ,p_dei_information4             in     varchar2  default null
  ,p_dei_information5             in     varchar2  default null
  ,p_dei_information6             in     varchar2  default null
  ,p_dei_information7             in     varchar2  default null
  ,p_dei_information8             in     varchar2  default null
  ,p_dei_information9             in     varchar2  default null
  ,p_dei_information10            in     varchar2  default null
  ,p_dei_information11            in     varchar2  default null
  ,p_dei_information12            in     varchar2  default null
  ,p_dei_information13            in     varchar2  default null
  ,p_dei_information14            in     varchar2  default null
  ,p_dei_information15            in     varchar2  default null
  ,p_dei_information16            in     varchar2  default null
  ,p_dei_information17            in     varchar2  default null
  ,p_dei_information18            in     varchar2  default null
  ,p_dei_information19            in     varchar2  default null
  ,p_dei_information20            in     varchar2  default null
  ,p_dei_information21            in     varchar2  default null
  ,p_dei_information22            in     varchar2  default null
  ,p_dei_information23            in     varchar2  default null
  ,p_dei_information24            in     varchar2  default null
  ,p_dei_information25            in     varchar2  default null
  ,p_dei_information26            in     varchar2  default null
  ,p_dei_information27            in     varchar2  default null
  ,p_dei_information28            in     varchar2  default null
  ,p_dei_information29            in     varchar2  default null
  ,p_dei_information30            in     varchar2  default null
  ,p_request_id                   in     number    default null
  ,p_program_application_id       in     number    default null
  ,p_program_id                   in     number    default null
  ,p_program_update_date          in     date      default null
  ,p_document_extra_info_id       in     number
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_document_extra_info_id       number;
  l_proc    varchar2(72) := g_package ||'create_doc_extra_info';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_doc_extra_info_swi;
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
  hr_dei_ins.set_base_key_value
    (p_document_extra_info_id => p_document_extra_info_id
    );
  --
  -- Call API
  --
  hr_document_extra_info_api.create_doc_extra_info
    (p_validate                     => l_validate
    ,p_person_id                    => p_person_id
    ,p_document_type_id             => p_document_type_id
    ,p_date_from                    => p_date_from
    ,p_date_to                      => p_date_to
    ,p_document_number              => p_document_number
    ,p_issued_by                    => p_issued_by
    ,p_issued_at                    => p_issued_at
    ,p_issued_date                  => p_issued_date
    ,p_issuing_authority            => p_issuing_authority
    ,p_verified_by                  => p_verified_by
    ,p_verified_date                => p_verified_date
    ,p_related_object_name          => p_related_object_name
    ,p_related_object_id_col        => p_related_object_id_col
    ,p_related_object_id            => p_related_object_id
    ,p_dei_attribute_category       => p_dei_attribute_category
    ,p_dei_attribute1               => p_dei_attribute1
    ,p_dei_attribute2               => p_dei_attribute2
    ,p_dei_attribute3               => p_dei_attribute3
    ,p_dei_attribute4               => p_dei_attribute4
    ,p_dei_attribute5               => p_dei_attribute5
    ,p_dei_attribute6               => p_dei_attribute6
    ,p_dei_attribute7               => p_dei_attribute7
    ,p_dei_attribute8               => p_dei_attribute8
    ,p_dei_attribute9               => p_dei_attribute9
    ,p_dei_attribute10              => p_dei_attribute10
    ,p_dei_attribute11              => p_dei_attribute11
    ,p_dei_attribute12              => p_dei_attribute12
    ,p_dei_attribute13              => p_dei_attribute13
    ,p_dei_attribute14              => p_dei_attribute14
    ,p_dei_attribute15              => p_dei_attribute15
    ,p_dei_attribute16              => p_dei_attribute16
    ,p_dei_attribute17              => p_dei_attribute17
    ,p_dei_attribute18              => p_dei_attribute18
    ,p_dei_attribute19              => p_dei_attribute19
    ,p_dei_attribute20              => p_dei_attribute20
    ,p_dei_attribute21              => p_dei_attribute21
    ,p_dei_attribute22              => p_dei_attribute22
    ,p_dei_attribute23              => p_dei_attribute23
    ,p_dei_attribute24              => p_dei_attribute24
    ,p_dei_attribute25              => p_dei_attribute25
    ,p_dei_attribute26              => p_dei_attribute26
    ,p_dei_attribute27              => p_dei_attribute27
    ,p_dei_attribute28              => p_dei_attribute28
    ,p_dei_attribute29              => p_dei_attribute29
    ,p_dei_attribute30              => p_dei_attribute30
    ,p_dei_information_category     => p_dei_information_category
    ,p_dei_information1             => p_dei_information1
    ,p_dei_information2             => p_dei_information2
    ,p_dei_information3             => p_dei_information3
    ,p_dei_information4             => p_dei_information4
    ,p_dei_information5             => p_dei_information5
    ,p_dei_information6             => p_dei_information6
    ,p_dei_information7             => p_dei_information7
    ,p_dei_information8             => p_dei_information8
    ,p_dei_information9             => p_dei_information9
    ,p_dei_information10            => p_dei_information10
    ,p_dei_information11            => p_dei_information11
    ,p_dei_information12            => p_dei_information12
    ,p_dei_information13            => p_dei_information13
    ,p_dei_information14            => p_dei_information14
    ,p_dei_information15            => p_dei_information15
    ,p_dei_information16            => p_dei_information16
    ,p_dei_information17            => p_dei_information17
    ,p_dei_information18            => p_dei_information18
    ,p_dei_information19            => p_dei_information19
    ,p_dei_information20            => p_dei_information20
    ,p_dei_information21            => p_dei_information21
    ,p_dei_information22            => p_dei_information22
    ,p_dei_information23            => p_dei_information23
    ,p_dei_information24            => p_dei_information24
    ,p_dei_information25            => p_dei_information25
    ,p_dei_information26            => p_dei_information26
    ,p_dei_information27            => p_dei_information27
    ,p_dei_information28            => p_dei_information28
    ,p_dei_information29            => p_dei_information29
    ,p_dei_information30            => p_dei_information30
    ,p_request_id                   => p_request_id
    ,p_program_application_id       => p_program_application_id
    ,p_program_id                   => p_program_id
    ,p_program_update_date          => p_program_update_date
    ,p_document_extra_info_id       => l_document_extra_info_id
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
    rollback to create_doc_extra_info_swi;
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
    rollback to create_doc_extra_info_swi;
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
end create_doc_extra_info;
-- ----------------------------------------------------------------------------
-- |-------------------------< update_doc_extra_info >------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_doc_extra_info
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_document_extra_info_id       in     number
  ,p_person_id                    in     number
  ,p_document_type_id             in     number
  ,p_date_from                    in     date
  ,p_date_to                      in     date  default  hr_api.g_date
  ,p_document_number              in     varchar2  default hr_api.g_varchar2
  ,p_issued_by                    in     varchar2  default hr_api.g_varchar2
  ,p_issued_at                    in     varchar2  default hr_api.g_varchar2
  ,p_issued_date                  in     date      default hr_api.g_date
  ,p_issuing_authority            in     varchar2  default hr_api.g_varchar2
  ,p_verified_by                  in     number    default hr_api.g_number
  ,p_verified_date                in     date      default hr_api.g_date
  ,p_related_object_name          in     varchar2  default hr_api.g_varchar2
  ,p_related_object_id_col        in     varchar2  default hr_api.g_varchar2
  ,p_related_object_id            in     number    default hr_api.g_number
  ,p_dei_attribute_category       in     varchar2  default hr_api.g_varchar2
  ,p_dei_attribute1               in     varchar2  default hr_api.g_varchar2
  ,p_dei_attribute2               in     varchar2  default hr_api.g_varchar2
  ,p_dei_attribute3               in     varchar2  default hr_api.g_varchar2
  ,p_dei_attribute4               in     varchar2  default hr_api.g_varchar2
  ,p_dei_attribute5               in     varchar2  default hr_api.g_varchar2
  ,p_dei_attribute6               in     varchar2  default hr_api.g_varchar2
  ,p_dei_attribute7               in     varchar2  default hr_api.g_varchar2
  ,p_dei_attribute8               in     varchar2  default hr_api.g_varchar2
  ,p_dei_attribute9               in     varchar2  default hr_api.g_varchar2
  ,p_dei_attribute10              in     varchar2  default hr_api.g_varchar2
  ,p_dei_attribute11              in     varchar2  default hr_api.g_varchar2
  ,p_dei_attribute12              in     varchar2  default hr_api.g_varchar2
  ,p_dei_attribute13              in     varchar2  default hr_api.g_varchar2
  ,p_dei_attribute14              in     varchar2  default hr_api.g_varchar2
  ,p_dei_attribute15              in     varchar2  default hr_api.g_varchar2
  ,p_dei_attribute16              in     varchar2  default hr_api.g_varchar2
  ,p_dei_attribute17              in     varchar2  default hr_api.g_varchar2
  ,p_dei_attribute18              in     varchar2  default hr_api.g_varchar2
  ,p_dei_attribute19              in     varchar2  default hr_api.g_varchar2
  ,p_dei_attribute20              in     varchar2  default hr_api.g_varchar2
  ,p_dei_attribute21              in     varchar2  default hr_api.g_varchar2
  ,p_dei_attribute22              in     varchar2  default hr_api.g_varchar2
  ,p_dei_attribute23              in     varchar2  default hr_api.g_varchar2
  ,p_dei_attribute24              in     varchar2  default hr_api.g_varchar2
  ,p_dei_attribute25              in     varchar2  default hr_api.g_varchar2
  ,p_dei_attribute26              in     varchar2  default hr_api.g_varchar2
  ,p_dei_attribute27              in     varchar2  default hr_api.g_varchar2
  ,p_dei_attribute28              in     varchar2  default hr_api.g_varchar2
  ,p_dei_attribute29              in     varchar2  default hr_api.g_varchar2
  ,p_dei_attribute30              in     varchar2  default hr_api.g_varchar2
  ,p_dei_information_category     in     varchar2  default hr_api.g_varchar2
  ,p_dei_information1             in     varchar2  default hr_api.g_varchar2
  ,p_dei_information2             in     varchar2  default hr_api.g_varchar2
  ,p_dei_information3             in     varchar2  default hr_api.g_varchar2
  ,p_dei_information4             in     varchar2  default hr_api.g_varchar2
  ,p_dei_information5             in     varchar2  default hr_api.g_varchar2
  ,p_dei_information6             in     varchar2  default hr_api.g_varchar2
  ,p_dei_information7             in     varchar2  default hr_api.g_varchar2
  ,p_dei_information8             in     varchar2  default hr_api.g_varchar2
  ,p_dei_information9             in     varchar2  default hr_api.g_varchar2
  ,p_dei_information10            in     varchar2  default hr_api.g_varchar2
  ,p_dei_information11            in     varchar2  default hr_api.g_varchar2
  ,p_dei_information12            in     varchar2  default hr_api.g_varchar2
  ,p_dei_information13            in     varchar2  default hr_api.g_varchar2
  ,p_dei_information14            in     varchar2  default hr_api.g_varchar2
  ,p_dei_information15            in     varchar2  default hr_api.g_varchar2
  ,p_dei_information16            in     varchar2  default hr_api.g_varchar2
  ,p_dei_information17            in     varchar2  default hr_api.g_varchar2
  ,p_dei_information18            in     varchar2  default hr_api.g_varchar2
  ,p_dei_information19            in     varchar2  default hr_api.g_varchar2
  ,p_dei_information20            in     varchar2  default hr_api.g_varchar2
  ,p_dei_information21            in     varchar2  default hr_api.g_varchar2
  ,p_dei_information22            in     varchar2  default hr_api.g_varchar2
  ,p_dei_information23            in     varchar2  default hr_api.g_varchar2
  ,p_dei_information24            in     varchar2  default hr_api.g_varchar2
  ,p_dei_information25            in     varchar2  default hr_api.g_varchar2
  ,p_dei_information26            in     varchar2  default hr_api.g_varchar2
  ,p_dei_information27            in     varchar2  default hr_api.g_varchar2
  ,p_dei_information28            in     varchar2  default hr_api.g_varchar2
  ,p_dei_information29            in     varchar2  default hr_api.g_varchar2
  ,p_dei_information30            in     varchar2  default hr_api.g_varchar2
  ,p_request_id                   in     number    default hr_api.g_number
  ,p_program_application_id       in     number    default hr_api.g_number
  ,p_program_id                   in     number    default hr_api.g_number
  ,p_program_update_date          in     date      default hr_api.g_date
  ,p_object_version_number        in out nocopy number
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
  l_proc    varchar2(72) := g_package ||'update_doc_extra_info';
  l_verified_date                     date;
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_doc_extra_info_swi;
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
  -- updating verified date
 if p_verified_by is not null then
    l_verified_date := sysdate;
 end if;
  --
  -- Call API
  --
  hr_document_extra_info_api.update_doc_extra_info
    (p_validate                     => l_validate
    ,p_document_extra_info_id       => p_document_extra_info_id
    ,p_person_id                    => p_person_id
    ,p_document_type_id             => p_document_type_id
    ,p_date_from                    => p_date_from
    ,p_date_to                      => p_date_to
    ,p_document_number              => p_document_number
    ,p_issued_by                    => p_issued_by
    ,p_issued_at                    => p_issued_at
    ,p_issued_date                  => p_issued_date
    ,p_issuing_authority            => p_issuing_authority
    ,p_verified_by                  => p_verified_by
    ,p_verified_date                => l_verified_date
    ,p_related_object_name          => p_related_object_name
    ,p_related_object_id_col        => p_related_object_id_col
    ,p_related_object_id            => p_related_object_id
    ,p_dei_attribute_category       => p_dei_attribute_category
    ,p_dei_attribute1               => p_dei_attribute1
    ,p_dei_attribute2               => p_dei_attribute2
    ,p_dei_attribute3               => p_dei_attribute3
    ,p_dei_attribute4               => p_dei_attribute4
    ,p_dei_attribute5               => p_dei_attribute5
    ,p_dei_attribute6               => p_dei_attribute6
    ,p_dei_attribute7               => p_dei_attribute7
    ,p_dei_attribute8               => p_dei_attribute8
    ,p_dei_attribute9               => p_dei_attribute9
    ,p_dei_attribute10              => p_dei_attribute10
    ,p_dei_attribute11              => p_dei_attribute11
    ,p_dei_attribute12              => p_dei_attribute12
    ,p_dei_attribute13              => p_dei_attribute13
    ,p_dei_attribute14              => p_dei_attribute14
    ,p_dei_attribute15              => p_dei_attribute15
    ,p_dei_attribute16              => p_dei_attribute16
    ,p_dei_attribute17              => p_dei_attribute17
    ,p_dei_attribute18              => p_dei_attribute18
    ,p_dei_attribute19              => p_dei_attribute19
    ,p_dei_attribute20              => p_dei_attribute20
    ,p_dei_attribute21              => p_dei_attribute21
    ,p_dei_attribute22              => p_dei_attribute22
    ,p_dei_attribute23              => p_dei_attribute23
    ,p_dei_attribute24              => p_dei_attribute24
    ,p_dei_attribute25              => p_dei_attribute25
    ,p_dei_attribute26              => p_dei_attribute26
    ,p_dei_attribute27              => p_dei_attribute27
    ,p_dei_attribute28              => p_dei_attribute28
    ,p_dei_attribute29              => p_dei_attribute29
    ,p_dei_attribute30              => p_dei_attribute30
    ,p_dei_information_category     => p_dei_information_category
    ,p_dei_information1             => p_dei_information1
    ,p_dei_information2             => p_dei_information2
    ,p_dei_information3             => p_dei_information3
    ,p_dei_information4             => p_dei_information4
    ,p_dei_information5             => p_dei_information5
    ,p_dei_information6             => p_dei_information6
    ,p_dei_information7             => p_dei_information7
    ,p_dei_information8             => p_dei_information8
    ,p_dei_information9             => p_dei_information9
    ,p_dei_information10            => p_dei_information10
    ,p_dei_information11            => p_dei_information11
    ,p_dei_information12            => p_dei_information12
    ,p_dei_information13            => p_dei_information13
    ,p_dei_information14            => p_dei_information14
    ,p_dei_information15            => p_dei_information15
    ,p_dei_information16            => p_dei_information16
    ,p_dei_information17            => p_dei_information17
    ,p_dei_information18            => p_dei_information18
    ,p_dei_information19            => p_dei_information19
    ,p_dei_information20            => p_dei_information20
    ,p_dei_information21            => p_dei_information21
    ,p_dei_information22            => p_dei_information22
    ,p_dei_information23            => p_dei_information23
    ,p_dei_information24            => p_dei_information24
    ,p_dei_information25            => p_dei_information25
    ,p_dei_information26            => p_dei_information26
    ,p_dei_information27            => p_dei_information27
    ,p_dei_information28            => p_dei_information28
    ,p_dei_information29            => p_dei_information29
    ,p_dei_information30            => p_dei_information30
    ,p_request_id                   => p_request_id
    ,p_program_application_id       => p_program_application_id
    ,p_program_id                   => p_program_id
    ,p_program_update_date          => p_program_update_date
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
    rollback to update_doc_extra_info_swi;
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
    rollback to update_doc_extra_info_swi;
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
end update_doc_extra_info;
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_doc_extra_info >------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_doc_extra_info
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_document_extra_info_id       in     number
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
  l_proc    varchar2(72) := g_package ||'delete_doc_extra_info';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_doc_extra_info_swi;
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
  hr_document_extra_info_api.delete_doc_extra_info
    (p_validate                     => l_validate
    ,p_document_extra_info_id       => p_document_extra_info_id
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
    rollback to delete_doc_extra_info_swi;
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
    rollback to delete_doc_extra_info_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end delete_doc_extra_info;
end hr_document_extra_info_swi;

/
