--------------------------------------------------------
--  DDL for Package PER_QUALIFICATIONS_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_QUALIFICATIONS_SWI" AUTHID CURRENT_USER As
/* $Header: pequaswi.pkh 115.1 2002/12/05 17:24:55 eumenyio ship $ */
-- ----------------------------------------------------------------------------
-- |-------------------------< create_qualification >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: per_qualifications_api.create_qualification
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
PROCEDURE create_qualification
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_qualification_type_id        in     number
  ,p_business_group_id            in     number    default null
  ,p_person_id                    in     number    default null
  ,p_title                        in     varchar2  default null
  ,p_grade_attained               in     varchar2  default null
  ,p_status                       in     varchar2  default null
  ,p_awarded_date                 in     date      default null
  ,p_fee                          in     number    default null
  ,p_fee_currency                 in     varchar2  default null
  ,p_training_completed_amount    in     number    default null
  ,p_reimbursement_arrangements   in     varchar2  default null
  ,p_training_completed_units     in     varchar2  default null
  ,p_total_training_amount        in     number    default null
  ,p_start_date                   in     date      default null
  ,p_end_date                     in     date      default null
  ,p_license_number               in     varchar2  default null
  ,p_expiry_date                  in     date      default null
  ,p_license_restrictions         in     varchar2  default null
  ,p_projected_completion_date    in     date      default null
  ,p_awarding_body                in     varchar2  default null
  ,p_tuition_method               in     varchar2  default null
  ,p_group_ranking                in     varchar2  default null
  ,p_comments                     in     varchar2  default null
  ,p_attendance_id                in     number    default null
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
  ,p_party_id                     in     number    default null
  ,p_qua_information_category     in     varchar2  default null
  ,p_qua_information1             in     varchar2  default null
  ,p_qua_information2             in     varchar2  default null
  ,p_qua_information3             in     varchar2  default null
  ,p_qua_information4             in     varchar2  default null
  ,p_qua_information5             in     varchar2  default null
  ,p_qua_information6             in     varchar2  default null
  ,p_qua_information7             in     varchar2  default null
  ,p_qua_information8             in     varchar2  default null
  ,p_qua_information9             in     varchar2  default null
  ,p_qua_information10            in     varchar2  default null
  ,p_qua_information11            in     varchar2  default null
  ,p_qua_information12            in     varchar2  default null
  ,p_qua_information13            in     varchar2  default null
  ,p_qua_information14            in     varchar2  default null
  ,p_qua_information15            in     varchar2  default null
  ,p_qua_information16            in     varchar2  default null
  ,p_qua_information17            in     varchar2  default null
  ,p_qua_information18            in     varchar2  default null
  ,p_qua_information19            in     varchar2  default null
  ,p_qua_information20            in     varchar2  default null
  ,p_professional_body_name       in     varchar2  default null
  ,p_membership_number            in     varchar2  default null
  ,p_membership_category          in     varchar2  default null
  ,p_subscription_payment_method  in     varchar2  default null
  ,p_qualification_id             in     number
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_qualification >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: per_qualifications_api.delete_qualification
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
PROCEDURE delete_qualification
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_qualification_id             in     number
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-------------------------< update_qualification >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: per_qualifications_api.update_qualification
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
PROCEDURE update_qualification
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_qualification_id             in     number
  ,p_qualification_type_id        in     number    default hr_api.g_number
  ,p_title                        in     varchar2  default hr_api.g_varchar2
  ,p_grade_attained               in     varchar2  default hr_api.g_varchar2
  ,p_status                       in     varchar2  default hr_api.g_varchar2
  ,p_awarded_date                 in     date      default hr_api.g_date
  ,p_fee                          in     number    default hr_api.g_number
  ,p_fee_currency                 in     varchar2  default hr_api.g_varchar2
  ,p_training_completed_amount    in     number    default hr_api.g_number
  ,p_reimbursement_arrangements   in     varchar2  default hr_api.g_varchar2
  ,p_training_completed_units     in     varchar2  default hr_api.g_varchar2
  ,p_total_training_amount        in     number    default hr_api.g_number
  ,p_start_date                   in     date      default hr_api.g_date
  ,p_end_date                     in     date      default hr_api.g_date
  ,p_license_number               in     varchar2  default hr_api.g_varchar2
  ,p_expiry_date                  in     date      default hr_api.g_date
  ,p_license_restrictions         in     varchar2  default hr_api.g_varchar2
  ,p_projected_completion_date    in     date      default hr_api.g_date
  ,p_awarding_body                in     varchar2  default hr_api.g_varchar2
  ,p_tuition_method               in     varchar2  default hr_api.g_varchar2
  ,p_group_ranking                in     varchar2  default hr_api.g_varchar2
  ,p_comments                     in     varchar2  default hr_api.g_varchar2
  ,p_attendance_id                in     number    default hr_api.g_number
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
  ,p_qua_information_category     in     varchar2  default hr_api.g_varchar2
  ,p_qua_information1             in     varchar2  default hr_api.g_varchar2
  ,p_qua_information2             in     varchar2  default hr_api.g_varchar2
  ,p_qua_information3             in     varchar2  default hr_api.g_varchar2
  ,p_qua_information4             in     varchar2  default hr_api.g_varchar2
  ,p_qua_information5             in     varchar2  default hr_api.g_varchar2
  ,p_qua_information6             in     varchar2  default hr_api.g_varchar2
  ,p_qua_information7             in     varchar2  default hr_api.g_varchar2
  ,p_qua_information8             in     varchar2  default hr_api.g_varchar2
  ,p_qua_information9             in     varchar2  default hr_api.g_varchar2
  ,p_qua_information10            in     varchar2  default hr_api.g_varchar2
  ,p_qua_information11            in     varchar2  default hr_api.g_varchar2
  ,p_qua_information12            in     varchar2  default hr_api.g_varchar2
  ,p_qua_information13            in     varchar2  default hr_api.g_varchar2
  ,p_qua_information14            in     varchar2  default hr_api.g_varchar2
  ,p_qua_information15            in     varchar2  default hr_api.g_varchar2
  ,p_qua_information16            in     varchar2  default hr_api.g_varchar2
  ,p_qua_information17            in     varchar2  default hr_api.g_varchar2
  ,p_qua_information18            in     varchar2  default hr_api.g_varchar2
  ,p_qua_information19            in     varchar2  default hr_api.g_varchar2
  ,p_qua_information20            in     varchar2  default hr_api.g_varchar2
  ,p_professional_body_name       in     varchar2  default hr_api.g_varchar2
  ,p_membership_number            in     varchar2  default hr_api.g_varchar2
  ,p_membership_category          in     varchar2  default hr_api.g_varchar2
  ,p_subscription_payment_method  in     varchar2  default hr_api.g_varchar2
  ,p_object_version_number        in out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
end per_qualifications_swi;

 

/
