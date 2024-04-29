--------------------------------------------------------
--  DDL for Package PER_QUALIFICATIONS_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_QUALIFICATIONS_BK2" AUTHID CURRENT_USER as
/* $Header: pequaapi.pkh 120.1.12010000.3 2009/03/12 11:30:11 dparthas ship $ */
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< UPDATE_QUALIFICATION_B >-----------------------|
-- ----------------------------------------------------------------------------
--

procedure UPDATE_QUALIFICATION_B
  (p_effective_date                in     date
  ,p_qualification_id              in     number
  ,p_qualification_type_id         in     number
  ,p_title                         in     varchar2
  ,p_grade_attained                in     varchar2
  ,p_status                        in     varchar2
  ,p_awarded_date                  in     date
  ,p_fee                           in     number
  ,p_fee_currency                  in     varchar2
  ,p_training_completed_amount     in     number
  ,p_reimbursement_arrangements    in     varchar2
  ,p_training_completed_units      in     varchar2
  ,p_total_training_amount         in     number
  ,p_start_date                    in     date
  ,p_end_date                      in     date
  ,p_license_number                in     varchar2
  ,p_expiry_date                   in     date
  ,p_license_restrictions          in     varchar2
  ,p_projected_completion_date     in     date
  ,p_awarding_body                 in     varchar2
  ,p_tuition_method                in     varchar2
  ,p_group_ranking                 in     varchar2
  ,p_comments                      in     varchar2
  ,p_attendance_id                 in     number
  ,p_attribute_category            in     varchar2
  ,p_attribute1                    in     varchar2
  ,p_attribute2                    in     varchar2
  ,p_attribute3                    in     varchar2
  ,p_attribute4                    in     varchar2
  ,p_attribute5                    in     varchar2
  ,p_attribute6                    in     varchar2
  ,p_attribute7                    in     varchar2
  ,p_attribute8                    in     varchar2
  ,p_attribute9                    in     varchar2
  ,p_attribute10                   in     varchar2
  ,p_attribute11                   in     varchar2
  ,p_attribute12                   in     varchar2
  ,p_attribute13                   in     varchar2
  ,p_attribute14                   in     varchar2
  ,p_attribute15                   in     varchar2
  ,p_attribute16                   in     varchar2
  ,p_attribute17                   in     varchar2
  ,p_attribute18                   in     varchar2
  ,p_attribute19                   in     varchar2
  ,p_attribute20                   in     varchar2
  ,p_qua_information_category      in     varchar2
  ,p_qua_information1              in     varchar2
  ,p_qua_information2              in     varchar2
  ,p_qua_information3              in     varchar2
  ,p_qua_information4              in     varchar2
  ,p_qua_information5              in     varchar2
  ,p_qua_information6              in     varchar2
  ,p_qua_information7              in     varchar2
  ,p_qua_information8              in     varchar2
  ,p_qua_information9              in     varchar2
  ,p_qua_information10             in     varchar2
  ,p_qua_information11             in     varchar2
  ,p_qua_information12             in     varchar2
  ,p_qua_information13             in     varchar2
  ,p_qua_information14             in     varchar2
  ,p_qua_information15             in     varchar2
  ,p_qua_information16             in     varchar2
  ,p_qua_information17             in     varchar2
  ,p_qua_information18             in     varchar2
  ,p_qua_information19             in     varchar2
  ,p_qua_information20             in     varchar2
  ,p_professional_body_name        in     varchar2
  ,p_membership_number             in     varchar2
  ,p_membership_category           in     varchar2
  ,p_subscription_payment_method   in     varchar2
  ,p_object_version_number         in     number
  ,p_language_code                 in     varchar2
  );
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< UPDATE_QUALIFICATION_A >-----------------------|
-- ----------------------------------------------------------------------------
--

procedure UPDATE_QUALIFICATION_A
  (p_effective_date                in     date
  ,p_qualification_id              in     number
  ,p_qualification_type_id         in     number
  ,p_title                         in     varchar2
  ,p_grade_attained                in     varchar2
  ,p_status                        in     varchar2
  ,p_awarded_date                  in     date
  ,p_fee                           in     number
  ,p_fee_currency                  in     varchar2
  ,p_training_completed_amount     in     number
  ,p_reimbursement_arrangements    in     varchar2
  ,p_training_completed_units      in     varchar2
  ,p_total_training_amount         in     number
  ,p_start_date                    in     date
  ,p_end_date                      in     date
  ,p_license_number                in     varchar2
  ,p_expiry_date                   in     date
  ,p_license_restrictions          in     varchar2
  ,p_projected_completion_date     in     date
  ,p_awarding_body                 in     varchar2
  ,p_tuition_method                in     varchar2
  ,p_group_ranking                 in     varchar2
  ,p_comments                      in     varchar2
  ,p_attendance_id                 in     number
  ,p_attribute_category            in     varchar2
  ,p_attribute1                    in     varchar2
  ,p_attribute2                    in     varchar2
  ,p_attribute3                    in     varchar2
  ,p_attribute4                    in     varchar2
  ,p_attribute5                    in     varchar2
  ,p_attribute6                    in     varchar2
  ,p_attribute7                    in     varchar2
  ,p_attribute8                    in     varchar2
  ,p_attribute9                    in     varchar2
  ,p_attribute10                   in     varchar2
  ,p_attribute11                   in     varchar2
  ,p_attribute12                   in     varchar2
  ,p_attribute13                   in     varchar2
  ,p_attribute14                   in     varchar2
  ,p_attribute15                   in     varchar2
  ,p_attribute16                   in     varchar2
  ,p_attribute17                   in     varchar2
  ,p_attribute18                   in     varchar2
  ,p_attribute19                   in     varchar2
  ,p_attribute20                   in     varchar2
  ,p_qua_information_category      in     varchar2
  ,p_qua_information1              in     varchar2
  ,p_qua_information2              in     varchar2
  ,p_qua_information3              in     varchar2
  ,p_qua_information4              in     varchar2
  ,p_qua_information5              in     varchar2
  ,p_qua_information6              in     varchar2
  ,p_qua_information7              in     varchar2
  ,p_qua_information8              in     varchar2
  ,p_qua_information9              in     varchar2
  ,p_qua_information10             in     varchar2
  ,p_qua_information11             in     varchar2
  ,p_qua_information12             in     varchar2
  ,p_qua_information13             in     varchar2
  ,p_qua_information14             in     varchar2
  ,p_qua_information15             in     varchar2
  ,p_qua_information16             in     varchar2
  ,p_qua_information17             in     varchar2
  ,p_qua_information18             in     varchar2
  ,p_qua_information19             in     varchar2
  ,p_qua_information20             in     varchar2
  ,p_professional_body_name        in     varchar2
  ,p_membership_number             in     varchar2
  ,p_membership_category           in     varchar2
  ,p_subscription_payment_method   in     varchar2
  ,p_object_version_number         in     number
  ,p_language_code                 in     varchar2
  );

--
end per_qualifications_bk2;

/
