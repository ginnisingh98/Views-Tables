--------------------------------------------------------
--  DDL for Package HR_DOCUMENT_EXTRA_INFO_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_DOCUMENT_EXTRA_INFO_SWI" AUTHID CURRENT_USER As
/* $Header: hrdeiswi.pkh 120.0.12010000.2 2010/04/07 11:36:23 tkghosh ship $ */
-- ----------------------------------------------------------------------------
-- |-------------------------< create_doc_extra_info >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_document_extra_info_api.create_doc_extra_info
--
-- Pre-requisites
--  All 'IN' parameters to this procedure have been appropriately derived.
--
-- Post Success:
--  p_return_status will return value indicating success.
--
-- Post Failure:
--  p_return_status will return value indication failure.
--
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
PROCEDURE create_doc_extra_info
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_person_id                    in     number
  ,p_document_type_id             in     number
  ,p_date_from                    in     date
  ,p_date_to                      in     date default null
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
  );
-- ----------------------------------------------------------------------------
-- |-------------------------< update_doc_extra_info >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_document_extra_info_api.update_doc_extra_info
--
-- Pre-requisites
--  All 'IN' parameters to this procedure have been appropriately derived.
--
-- Post Success:
--  p_return_status will return value indicating success.
--
-- Post Failure:
--  p_return_status will return value indication failure.
--
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
PROCEDURE update_doc_extra_info
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_document_extra_info_id       in     number
  ,p_person_id                    in     number
  ,p_document_type_id             in     number
  ,p_date_from                    in     date
  ,p_date_to                      in     date  default hr_api.g_date
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
  );
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_doc_extra_info >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_document_extra_info_api.delete_doc_extra_info
--
-- Pre-requisites
--  All 'IN' parameters to this procedure have been appropriately derived.
--
-- Post Success:
--  p_return_status will return value indicating success.
--
-- Post Failure:
--  p_return_status will return value indication failure.
--
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
PROCEDURE delete_doc_extra_info
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_document_extra_info_id       in     number
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  );
 end hr_document_extra_info_swi;

/