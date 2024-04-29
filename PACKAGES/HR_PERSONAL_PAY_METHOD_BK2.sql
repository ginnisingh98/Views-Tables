--------------------------------------------------------
--  DDL for Package HR_PERSONAL_PAY_METHOD_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PERSONAL_PAY_METHOD_BK2" AUTHID CURRENT_USER as
/* $Header: pyppmapi.pkh 120.4.12010000.4 2009/07/24 09:45:52 pgongada ship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------< update_personal_pay_method_b >---------------------|
-- ----------------------------------------------------------------------------
--
procedure update_personal_pay_method_b
  (p_effective_date                in     date
  ,p_datetrack_update_mode         in     varchar2
  ,p_personal_payment_method_id    in     number
  ,p_object_version_number         in     number
  ,p_amount                        in     number
  ,p_comments                      in     varchar2
  ,p_percentage                    in     number
  ,p_priority                      in     number
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
  ,p_territory_code                in     varchar2
  ,p_segment1                      in     varchar2
  ,p_segment2                      in     varchar2
  ,p_segment3                      in     varchar2
  ,p_segment4                      in     varchar2
  ,p_segment5                      in     varchar2
  ,p_segment6                      in     varchar2
  ,p_segment7                      in     varchar2
  ,p_segment8                      in     varchar2
  ,p_segment9                      in     varchar2
  ,p_segment10                     in     varchar2
  ,p_segment11                     in     varchar2
  ,p_segment12                     in     varchar2
  ,p_segment13                     in     varchar2
  ,p_segment14                     in     varchar2
  ,p_segment15                     in     varchar2
  ,p_segment16                     in     varchar2
  ,p_segment17                     in     varchar2
  ,p_segment18                     in     varchar2
  ,p_segment19                     in     varchar2
  ,p_segment20                     in     varchar2
  ,p_segment21                     in     varchar2
  ,p_segment22                     in     varchar2
  ,p_segment23                     in     varchar2
  ,p_segment24                     in     varchar2
  ,p_segment25                     in     varchar2
  ,p_segment26                     in     varchar2
  ,p_segment27                     in     varchar2
  ,p_segment28                     in     varchar2
  ,p_segment29                     in     varchar2
  ,p_segment30                     in     varchar2
  ,p_payee_type                    in     varchar2
  ,p_payee_id                      in     number
  ,p_ppm_information1              in     varchar2
  ,p_ppm_information2              in     varchar2
  ,p_ppm_information3              in     varchar2
  ,p_ppm_information4              in     varchar2
  ,p_ppm_information5              in     varchar2
  ,p_ppm_information6              in     varchar2
  ,p_ppm_information7              in     varchar2
  ,p_ppm_information8              in     varchar2
  ,p_ppm_information9              in     varchar2
  ,p_ppm_information10             in     varchar2
  ,p_ppm_information11             in     varchar2
  ,p_ppm_information12             in     varchar2
  ,p_ppm_information13             in     varchar2
  ,p_ppm_information14             in     varchar2
  ,p_ppm_information15             in     varchar2
  ,p_ppm_information16             in     varchar2
  ,p_ppm_information17             in     varchar2
  ,p_ppm_information18             in     varchar2
  ,p_ppm_information19             in     varchar2
  ,p_ppm_information20             in     varchar2
  ,p_ppm_information21             in     varchar2
  ,p_ppm_information22             in     varchar2
  ,p_ppm_information23             in     varchar2
  ,p_ppm_information24             in     varchar2
  ,p_ppm_information25             in     varchar2
  ,p_ppm_information26             in     varchar2
  ,p_ppm_information27             in     varchar2
  ,p_ppm_information28             in     varchar2
  ,p_ppm_information29             in     varchar2
  ,p_ppm_information30             in     varchar2
  ,p_ppm_information_category      in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------< update_personal_pay_method_a >---------------------|
-- ----------------------------------------------------------------------------
--
procedure update_personal_pay_method_a
  (p_effective_date                in     date
  ,p_datetrack_update_mode         in     varchar2
  ,p_personal_payment_method_id    in     number
  ,p_object_version_number         in     number
  ,p_amount                        in     number
  ,p_comments                      in     varchar2
  ,p_percentage                    in     number
  ,p_priority                      in     number
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
  ,p_territory_code                in     varchar2
  ,p_segment1                      in     varchar2
  ,p_segment2                      in     varchar2
  ,p_segment3                      in     varchar2
  ,p_segment4                      in     varchar2
  ,p_segment5                      in     varchar2
  ,p_segment6                      in     varchar2
  ,p_segment7                      in     varchar2
  ,p_segment8                      in     varchar2
  ,p_segment9                      in     varchar2
  ,p_segment10                     in     varchar2
  ,p_segment11                     in     varchar2
  ,p_segment12                     in     varchar2
  ,p_segment13                     in     varchar2
  ,p_segment14                     in     varchar2
  ,p_segment15                     in     varchar2
  ,p_segment16                     in     varchar2
  ,p_segment17                     in     varchar2
  ,p_segment18                     in     varchar2
  ,p_segment19                     in     varchar2
  ,p_segment20                     in     varchar2
  ,p_segment21                     in     varchar2
  ,p_segment22                     in     varchar2
  ,p_segment23                     in     varchar2
  ,p_segment24                     in     varchar2
  ,p_segment25                     in     varchar2
  ,p_segment26                     in     varchar2
  ,p_segment27                     in     varchar2
  ,p_segment28                     in     varchar2
  ,p_segment29                     in     varchar2
  ,p_segment30                     in     varchar2
  ,p_payee_type                    in     varchar2
  ,p_payee_id                      in     number
  ,p_comment_id                    in     number
  ,p_external_account_id           in     number
  ,p_effective_start_date          in     date
  ,p_effective_end_date            in     date
  ,p_ppm_information1              in     varchar2
  ,p_ppm_information2              in     varchar2
  ,p_ppm_information3              in     varchar2
  ,p_ppm_information4              in     varchar2
  ,p_ppm_information5              in     varchar2
  ,p_ppm_information6              in     varchar2
  ,p_ppm_information7              in     varchar2
  ,p_ppm_information8              in     varchar2
  ,p_ppm_information9              in     varchar2
  ,p_ppm_information10             in     varchar2
  ,p_ppm_information11             in     varchar2
  ,p_ppm_information12             in     varchar2
  ,p_ppm_information13             in     varchar2
  ,p_ppm_information14             in     varchar2
  ,p_ppm_information15             in     varchar2
  ,p_ppm_information16             in     varchar2
  ,p_ppm_information17             in     varchar2
  ,p_ppm_information18             in     varchar2
  ,p_ppm_information19             in     varchar2
  ,p_ppm_information20             in     varchar2
  ,p_ppm_information21             in     varchar2
  ,p_ppm_information22             in     varchar2
  ,p_ppm_information23             in     varchar2
  ,p_ppm_information24             in     varchar2
  ,p_ppm_information25             in     varchar2
  ,p_ppm_information26             in     varchar2
  ,p_ppm_information27             in     varchar2
  ,p_ppm_information28             in     varchar2
  ,p_ppm_information29             in     varchar2
  ,p_ppm_information30             in     varchar2
  ,p_ppm_information_category      in     varchar2
  );
--
end hr_personal_pay_method_bk2;

/
