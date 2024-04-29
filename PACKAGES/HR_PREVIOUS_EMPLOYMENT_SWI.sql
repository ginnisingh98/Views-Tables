--------------------------------------------------------
--  DDL for Package HR_PREVIOUS_EMPLOYMENT_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PREVIOUS_EMPLOYMENT_SWI" AUTHID CURRENT_USER As
/* $Header: hrpemswi.pkh 115.2 2002/12/04 07:14:27 hjonnala ship $ */
-- ----------------------------------------------------------------------------
-- |-----------------------< create_previous_employer >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_previous_employment_api.create_previous_employer
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
PROCEDURE create_previous_employer
  (p_effective_date               in     date
  ,p_validate                     in     number    default hr_api.g_false_num
  ,p_business_group_id            in     number
  ,p_person_id                    in     number
  ,p_party_id                     in     number
  ,p_start_date                   in     date      default null
  ,p_end_date                     in     date      default null
  ,p_period_years                 in     number    default null
  ,p_period_months                in     number    default null
  ,p_period_days                  in     number    default null
  ,p_employer_name                in     varchar2  default null
  ,p_employer_country             in     varchar2  default null
  ,p_employer_address             in     varchar2  default null
  ,p_employer_type                in     varchar2  default null
  ,p_employer_subtype             in     varchar2  default null
  ,p_description                  in     varchar2  default null
  ,p_all_assignments              in     varchar2  default null
  ,p_pem_attribute_category       in     varchar2  default null
  ,p_pem_attribute1               in     varchar2  default null
  ,p_pem_attribute2               in     varchar2  default null
  ,p_pem_attribute3               in     varchar2  default null
  ,p_pem_attribute4               in     varchar2  default null
  ,p_pem_attribute5               in     varchar2  default null
  ,p_pem_attribute6               in     varchar2  default null
  ,p_pem_attribute7               in     varchar2  default null
  ,p_pem_attribute8               in     varchar2  default null
  ,p_pem_attribute9               in     varchar2  default null
  ,p_pem_attribute10              in     varchar2  default null
  ,p_pem_attribute11              in     varchar2  default null
  ,p_pem_attribute12              in     varchar2  default null
  ,p_pem_attribute13              in     varchar2  default null
  ,p_pem_attribute14              in     varchar2  default null
  ,p_pem_attribute15              in     varchar2  default null
  ,p_pem_attribute16              in     varchar2  default null
  ,p_pem_attribute17              in     varchar2  default null
  ,p_pem_attribute18              in     varchar2  default null
  ,p_pem_attribute19              in     varchar2  default null
  ,p_pem_attribute20              in     varchar2  default null
  ,p_pem_attribute21              in     varchar2  default null
  ,p_pem_attribute22              in     varchar2  default null
  ,p_pem_attribute23              in     varchar2  default null
  ,p_pem_attribute24              in     varchar2  default null
  ,p_pem_attribute25              in     varchar2  default null
  ,p_pem_attribute26              in     varchar2  default null
  ,p_pem_attribute27              in     varchar2  default null
  ,p_pem_attribute28              in     varchar2  default null
  ,p_pem_attribute29              in     varchar2  default null
  ,p_pem_attribute30              in     varchar2  default null
  ,p_pem_information_category     in     varchar2  default null
  ,p_pem_information1             in     varchar2  default null
  ,p_pem_information2             in     varchar2  default null
  ,p_pem_information3             in     varchar2  default null
  ,p_pem_information4             in     varchar2  default null
  ,p_pem_information5             in     varchar2  default null
  ,p_pem_information6             in     varchar2  default null
  ,p_pem_information7             in     varchar2  default null
  ,p_pem_information8             in     varchar2  default null
  ,p_pem_information9             in     varchar2  default null
  ,p_pem_information10            in     varchar2  default null
  ,p_pem_information11            in     varchar2  default null
  ,p_pem_information12            in     varchar2  default null
  ,p_pem_information13            in     varchar2  default null
  ,p_pem_information14            in     varchar2  default null
  ,p_pem_information15            in     varchar2  default null
  ,p_pem_information16            in     varchar2  default null
  ,p_pem_information17            in     varchar2  default null
  ,p_pem_information18            in     varchar2  default null
  ,p_pem_information19            in     varchar2  default null
  ,p_pem_information20            in     varchar2  default null
  ,p_pem_information21            in     varchar2  default null
  ,p_pem_information22            in     varchar2  default null
  ,p_pem_information23            in     varchar2  default null
  ,p_pem_information24            in     varchar2  default null
  ,p_pem_information25            in     varchar2  default null
  ,p_pem_information26            in     varchar2  default null
  ,p_pem_information27            in     varchar2  default null
  ,p_pem_information28            in     varchar2  default null
  ,p_pem_information29            in     varchar2  default null
  ,p_pem_information30            in     varchar2  default null
  ,p_previous_employer_id         in     number
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_previous_employer >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_previous_employment_api.delete_previous_employer
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
PROCEDURE delete_previous_employer
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_previous_employer_id         in     number
  ,p_object_version_number        in out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-----------------------< update_previous_employer >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_previous_employment_api.update_previous_employer
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
PROCEDURE update_previous_employer
  (p_effective_date               in     date
  ,p_validate                     in     number    default hr_api.g_false_num
  ,p_previous_employer_id         in     number
  ,p_start_date                   in     date      default hr_api.g_date
  ,p_end_date                     in     date      default hr_api.g_date
  ,p_period_years                 in     number    default hr_api.g_number
  ,p_period_months                in     number    default hr_api.g_number
  ,p_period_days                  in     number    default hr_api.g_number
  ,p_employer_name                in     varchar2  default hr_api.g_varchar2
  ,p_employer_country             in     varchar2  default hr_api.g_varchar2
  ,p_employer_address             in     varchar2  default hr_api.g_varchar2
  ,p_employer_type                in     varchar2  default hr_api.g_varchar2
  ,p_employer_subtype             in     varchar2  default hr_api.g_varchar2
  ,p_description                  in     varchar2  default hr_api.g_varchar2
  ,p_all_assignments              in     varchar2  default hr_api.g_varchar2
  ,p_pem_attribute_category       in     varchar2  default hr_api.g_varchar2
  ,p_pem_attribute1               in     varchar2  default hr_api.g_varchar2
  ,p_pem_attribute2               in     varchar2  default hr_api.g_varchar2
  ,p_pem_attribute3               in     varchar2  default hr_api.g_varchar2
  ,p_pem_attribute4               in     varchar2  default hr_api.g_varchar2
  ,p_pem_attribute5               in     varchar2  default hr_api.g_varchar2
  ,p_pem_attribute6               in     varchar2  default hr_api.g_varchar2
  ,p_pem_attribute7               in     varchar2  default hr_api.g_varchar2
  ,p_pem_attribute8               in     varchar2  default hr_api.g_varchar2
  ,p_pem_attribute9               in     varchar2  default hr_api.g_varchar2
  ,p_pem_attribute10              in     varchar2  default hr_api.g_varchar2
  ,p_pem_attribute11              in     varchar2  default hr_api.g_varchar2
  ,p_pem_attribute12              in     varchar2  default hr_api.g_varchar2
  ,p_pem_attribute13              in     varchar2  default hr_api.g_varchar2
  ,p_pem_attribute14              in     varchar2  default hr_api.g_varchar2
  ,p_pem_attribute15              in     varchar2  default hr_api.g_varchar2
  ,p_pem_attribute16              in     varchar2  default hr_api.g_varchar2
  ,p_pem_attribute17              in     varchar2  default hr_api.g_varchar2
  ,p_pem_attribute18              in     varchar2  default hr_api.g_varchar2
  ,p_pem_attribute19              in     varchar2  default hr_api.g_varchar2
  ,p_pem_attribute20              in     varchar2  default hr_api.g_varchar2
  ,p_pem_attribute21              in     varchar2  default hr_api.g_varchar2
  ,p_pem_attribute22              in     varchar2  default hr_api.g_varchar2
  ,p_pem_attribute23              in     varchar2  default hr_api.g_varchar2
  ,p_pem_attribute24              in     varchar2  default hr_api.g_varchar2
  ,p_pem_attribute25              in     varchar2  default hr_api.g_varchar2
  ,p_pem_attribute26              in     varchar2  default hr_api.g_varchar2
  ,p_pem_attribute27              in     varchar2  default hr_api.g_varchar2
  ,p_pem_attribute28              in     varchar2  default hr_api.g_varchar2
  ,p_pem_attribute29              in     varchar2  default hr_api.g_varchar2
  ,p_pem_attribute30              in     varchar2  default hr_api.g_varchar2
  ,p_pem_information_category     in     varchar2  default hr_api.g_varchar2
  ,p_pem_information1             in     varchar2  default hr_api.g_varchar2
  ,p_pem_information2             in     varchar2  default hr_api.g_varchar2
  ,p_pem_information3             in     varchar2  default hr_api.g_varchar2
  ,p_pem_information4             in     varchar2  default hr_api.g_varchar2
  ,p_pem_information5             in     varchar2  default hr_api.g_varchar2
  ,p_pem_information6             in     varchar2  default hr_api.g_varchar2
  ,p_pem_information7             in     varchar2  default hr_api.g_varchar2
  ,p_pem_information8             in     varchar2  default hr_api.g_varchar2
  ,p_pem_information9             in     varchar2  default hr_api.g_varchar2
  ,p_pem_information10            in     varchar2  default hr_api.g_varchar2
  ,p_pem_information11            in     varchar2  default hr_api.g_varchar2
  ,p_pem_information12            in     varchar2  default hr_api.g_varchar2
  ,p_pem_information13            in     varchar2  default hr_api.g_varchar2
  ,p_pem_information14            in     varchar2  default hr_api.g_varchar2
  ,p_pem_information15            in     varchar2  default hr_api.g_varchar2
  ,p_pem_information16            in     varchar2  default hr_api.g_varchar2
  ,p_pem_information17            in     varchar2  default hr_api.g_varchar2
  ,p_pem_information18            in     varchar2  default hr_api.g_varchar2
  ,p_pem_information19            in     varchar2  default hr_api.g_varchar2
  ,p_pem_information20            in     varchar2  default hr_api.g_varchar2
  ,p_pem_information21            in     varchar2  default hr_api.g_varchar2
  ,p_pem_information22            in     varchar2  default hr_api.g_varchar2
  ,p_pem_information23            in     varchar2  default hr_api.g_varchar2
  ,p_pem_information24            in     varchar2  default hr_api.g_varchar2
  ,p_pem_information25            in     varchar2  default hr_api.g_varchar2
  ,p_pem_information26            in     varchar2  default hr_api.g_varchar2
  ,p_pem_information27            in     varchar2  default hr_api.g_varchar2
  ,p_pem_information28            in     varchar2  default hr_api.g_varchar2
  ,p_pem_information29            in     varchar2  default hr_api.g_varchar2
  ,p_pem_information30            in     varchar2  default hr_api.g_varchar2
  ,p_object_version_number        in out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |--------------------------< create_previous_job >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_previous_employment_api.create_previous_job
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
PROCEDURE create_previous_job
  (p_effective_date               in     date
  ,p_validate                     in     number    default hr_api.g_false_num
  ,p_previous_employer_id         in     number
  ,p_start_date                   in     date      default null
  ,p_end_date                     in     date      default null
  ,p_period_years                 in     number    default null
  ,p_period_months                in     number    default null
  ,p_period_days                  in     number    default null
  ,p_job_name                     in     varchar2  default null
  ,p_employment_category          in     varchar2  default null
  ,p_description                  in     varchar2  default null
  ,p_all_assignments              in     varchar2  default null
  ,p_pjo_attribute_category       in     varchar2  default null
  ,p_pjo_attribute1               in     varchar2  default null
  ,p_pjo_attribute2               in     varchar2  default null
  ,p_pjo_attribute3               in     varchar2  default null
  ,p_pjo_attribute4               in     varchar2  default null
  ,p_pjo_attribute5               in     varchar2  default null
  ,p_pjo_attribute6               in     varchar2  default null
  ,p_pjo_attribute7               in     varchar2  default null
  ,p_pjo_attribute8               in     varchar2  default null
  ,p_pjo_attribute9               in     varchar2  default null
  ,p_pjo_attribute10              in     varchar2  default null
  ,p_pjo_attribute11              in     varchar2  default null
  ,p_pjo_attribute12              in     varchar2  default null
  ,p_pjo_attribute13              in     varchar2  default null
  ,p_pjo_attribute14              in     varchar2  default null
  ,p_pjo_attribute15              in     varchar2  default null
  ,p_pjo_attribute16              in     varchar2  default null
  ,p_pjo_attribute17              in     varchar2  default null
  ,p_pjo_attribute18              in     varchar2  default null
  ,p_pjo_attribute19              in     varchar2  default null
  ,p_pjo_attribute20              in     varchar2  default null
  ,p_pjo_attribute21              in     varchar2  default null
  ,p_pjo_attribute22              in     varchar2  default null
  ,p_pjo_attribute23              in     varchar2  default null
  ,p_pjo_attribute24              in     varchar2  default null
  ,p_pjo_attribute25              in     varchar2  default null
  ,p_pjo_attribute26              in     varchar2  default null
  ,p_pjo_attribute27              in     varchar2  default null
  ,p_pjo_attribute28              in     varchar2  default null
  ,p_pjo_attribute29              in     varchar2  default null
  ,p_pjo_attribute30              in     varchar2  default null
  ,p_pjo_information_category     in     varchar2  default null
  ,p_pjo_information1             in     varchar2  default null
  ,p_pjo_information2             in     varchar2  default null
  ,p_pjo_information3             in     varchar2  default null
  ,p_pjo_information4             in     varchar2  default null
  ,p_pjo_information5             in     varchar2  default null
  ,p_pjo_information6             in     varchar2  default null
  ,p_pjo_information7             in     varchar2  default null
  ,p_pjo_information8             in     varchar2  default null
  ,p_pjo_information9             in     varchar2  default null
  ,p_pjo_information10            in     varchar2  default null
  ,p_pjo_information11            in     varchar2  default null
  ,p_pjo_information12            in     varchar2  default null
  ,p_pjo_information13            in     varchar2  default null
  ,p_pjo_information14            in     varchar2  default null
  ,p_pjo_information15            in     varchar2  default null
  ,p_pjo_information16            in     varchar2  default null
  ,p_pjo_information17            in     varchar2  default null
  ,p_pjo_information18            in     varchar2  default null
  ,p_pjo_information19            in     varchar2  default null
  ,p_pjo_information20            in     varchar2  default null
  ,p_pjo_information21            in     varchar2  default null
  ,p_pjo_information22            in     varchar2  default null
  ,p_pjo_information23            in     varchar2  default null
  ,p_pjo_information24            in     varchar2  default null
  ,p_pjo_information25            in     varchar2  default null
  ,p_pjo_information26            in     varchar2  default null
  ,p_pjo_information27            in     varchar2  default null
  ,p_pjo_information28            in     varchar2  default null
  ,p_pjo_information29            in     varchar2  default null
  ,p_pjo_information30            in     varchar2  default null
  ,p_previous_job_id              in     number
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_previous_job >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_previous_employment_api.delete_previous_job
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
PROCEDURE delete_previous_job
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_previous_job_id              in     number
  ,p_object_version_number        in out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |--------------------------< update_previous_job >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_previous_employment_api.update_previous_job
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
PROCEDURE update_previous_job
  (p_effective_date               in     date
  ,p_validate                     in     number    default hr_api.g_false_num
  ,p_previous_job_id              in     number
  ,p_start_date                   in     date      default hr_api.g_date
  ,p_end_date                     in     date      default hr_api.g_date
  ,p_period_years                 in     number    default hr_api.g_number
  ,p_period_months                in     number    default hr_api.g_number
  ,p_period_days                  in     number    default hr_api.g_number
  ,p_job_name                     in     varchar2  default hr_api.g_varchar2
  ,p_employment_category          in     varchar2  default hr_api.g_varchar2
  ,p_description                  in     varchar2  default hr_api.g_varchar2
  ,p_all_assignments              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute_category       in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute1               in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute2               in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute3               in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute4               in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute5               in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute6               in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute7               in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute8               in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute9               in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute10              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute11              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute12              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute13              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute14              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute15              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute16              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute17              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute18              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute19              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute20              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute21              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute22              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute23              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute24              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute25              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute26              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute27              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute28              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute29              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute30              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information_category     in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information1             in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information2             in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information3             in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information4             in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information5             in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information6             in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information7             in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information8             in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information9             in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information10            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information11            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information12            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information13            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information14            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information15            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information16            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information17            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information18            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information19            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information20            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information21            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information22            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information23            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information24            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information25            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information26            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information27            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information28            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information29            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information30            in     varchar2  default hr_api.g_varchar2
  ,p_object_version_number        in out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
end hr_previous_employment_swi;

 

/
