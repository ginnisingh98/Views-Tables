--------------------------------------------------------
--  DDL for Package OTA_EXTERNAL_LEARNING_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_EXTERNAL_LEARNING_SWI" AUTHID CURRENT_USER As
/* $Header: otnhsswi.pkh 120.0 2005/05/29 07:27 appldev noship $ */
-- ----------------------------------------------------------------------------
-- |-----------------------< create_external_learning >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ota_external_learning_api.create_external_learning
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
PROCEDURE create_external_learning
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_nota_history_id              in     number
  ,p_person_id                    in     number
  ,p_contact_id                   in     number    default null
  ,p_trng_title                   in     varchar2
  ,p_provider                     in     varchar2
  ,p_type                         in     varchar2  default null
  ,p_centre                       in     varchar2  default null
  ,p_completion_date              in     date
  ,p_award                        in     varchar2  default null
  ,p_rating                       in     varchar2  default null
  ,p_duration                     in     number    default null
  ,p_duration_units               in     varchar2  default null
  ,p_activity_version_id          in     number    default null
  ,p_status                       in     varchar2  default null
  ,p_verified_by_id               in     number    default null
  ,p_nth_information_category     in     varchar2  default null
  ,p_nth_information1             in     varchar2  default null
  ,p_nth_information2             in     varchar2  default null
  ,p_nth_information3             in     varchar2  default null
  ,p_nth_information4             in     varchar2  default null
  ,p_nth_information5             in     varchar2  default null
  ,p_nth_information6             in     varchar2  default null
  ,p_nth_information7             in     varchar2  default null
  ,p_nth_information8             in     varchar2  default null
  ,p_nth_information9             in     varchar2  default null
  ,p_nth_information10            in     varchar2  default null
  ,p_nth_information11            in     varchar2  default null
  ,p_nth_information12            in     varchar2  default null
  ,p_nth_information13            in     varchar2  default null
  ,p_nth_information15            in     varchar2  default null
  ,p_nth_information16            in     varchar2  default null
  ,p_nth_information17            in     varchar2  default null
  ,p_nth_information18            in     varchar2  default null
  ,p_nth_information19            in     varchar2  default null
  ,p_nth_information20            in     varchar2  default null
  ,p_org_id                       in     number    default null
  ,p_object_version_number           out nocopy number
  ,p_business_group_id            in     number
  ,p_nth_information14            in     varchar2  default null
  ,p_customer_id                  in     number    default null
  ,p_organization_id              in     number    default null
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-----------------------< update_external_learning >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ota_external_learning_api.update_external_learning
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
PROCEDURE update_external_learning
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_nota_history_id              in     number
  ,p_person_id                    in     number
  ,p_contact_id                   in     number    default hr_api.g_number
  ,p_trng_title                   in     varchar2
  ,p_provider                     in     varchar2
  ,p_type                         in     varchar2  default hr_api.g_varchar2
  ,p_centre                       in     varchar2  default hr_api.g_varchar2
  ,p_completion_date              in     date
  ,p_award                        in     varchar2  default hr_api.g_varchar2
  ,p_rating                       in     varchar2  default hr_api.g_varchar2
  ,p_duration                     in     number    default hr_api.g_number
  ,p_duration_units               in     varchar2  default hr_api.g_varchar2
  ,p_activity_version_id          in     number    default hr_api.g_number
  ,p_status                       in     varchar2  default hr_api.g_varchar2
  ,p_verified_by_id               in     number    default hr_api.g_number
  ,p_nth_information_category     in     varchar2  default hr_api.g_varchar2
  ,p_nth_information1             in     varchar2  default hr_api.g_varchar2
  ,p_nth_information2             in     varchar2  default hr_api.g_varchar2
  ,p_nth_information3             in     varchar2  default hr_api.g_varchar2
  ,p_nth_information4             in     varchar2  default hr_api.g_varchar2
  ,p_nth_information5             in     varchar2  default hr_api.g_varchar2
  ,p_nth_information6             in     varchar2  default hr_api.g_varchar2
  ,p_nth_information7             in     varchar2  default hr_api.g_varchar2
  ,p_nth_information8             in     varchar2  default hr_api.g_varchar2
  ,p_nth_information9             in     varchar2  default hr_api.g_varchar2
  ,p_nth_information10            in     varchar2  default hr_api.g_varchar2
  ,p_nth_information11            in     varchar2  default hr_api.g_varchar2
  ,p_nth_information12            in     varchar2  default hr_api.g_varchar2
  ,p_nth_information13            in     varchar2  default hr_api.g_varchar2
  ,p_nth_information15            in     varchar2  default hr_api.g_varchar2
  ,p_nth_information16            in     varchar2  default hr_api.g_varchar2
  ,p_nth_information17            in     varchar2  default hr_api.g_varchar2
  ,p_nth_information18            in     varchar2  default hr_api.g_varchar2
  ,p_nth_information19            in     varchar2  default hr_api.g_varchar2
  ,p_nth_information20            in     varchar2  default hr_api.g_varchar2
  ,p_org_id                       in     number    default hr_api.g_number
  ,p_object_version_number        in out nocopy number
  ,p_business_group_id            in     number
  ,p_nth_information14            in     varchar2  default hr_api.g_varchar2
  ,p_customer_id                  in     number    default hr_api.g_number
  ,p_organization_id              in     number    default hr_api.g_number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_external_learning >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ota_external_learning_api.delete_external_learning
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
PROCEDURE delete_external_learning
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_nota_history_id              in     number
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  );
 end ota_external_learning_swi;

 

/
