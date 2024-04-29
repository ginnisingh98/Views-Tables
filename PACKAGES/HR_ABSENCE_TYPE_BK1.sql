--------------------------------------------------------
--  DDL for Package HR_ABSENCE_TYPE_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ABSENCE_TYPE_BK1" AUTHID CURRENT_USER as
/* $Header: peabbapi.pkh 120.4.12010000.1 2008/07/28 03:59:56 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_absence_type_b >------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_absence_type_b
  (p_language_code                 in  varchar2
  ,p_business_group_id             in  number
  ,p_input_value_id                in  number
  ,p_date_effective                in  date
  ,p_date_end                      in  date
  ,p_name                          in  varchar2
  ,p_absence_category              in  varchar2
  ,p_comments                      in  varchar2
  ,p_hours_or_days                 in  varchar2
  ,p_inc_or_dec_flag               in  varchar2
  ,p_attribute_category            in  varchar2
  ,p_attribute1                    in  varchar2
  ,p_attribute2                    in  varchar2
  ,p_attribute3                    in  varchar2
  ,p_attribute4                    in  varchar2
  ,p_attribute5                    in  varchar2
  ,p_attribute6                    in  varchar2
  ,p_attribute7                    in  varchar2
  ,p_attribute8                    in  varchar2
  ,p_attribute9                    in  varchar2
  ,p_attribute10                   in  varchar2
  ,p_attribute11                   in  varchar2
  ,p_attribute12                   in  varchar2
  ,p_attribute13                   in  varchar2
  ,p_attribute14                   in  varchar2
  ,p_attribute15                   in  varchar2
  ,p_attribute16                   in  varchar2
  ,p_attribute17                   in  varchar2
  ,p_attribute18                   in  varchar2
  ,p_attribute19                   in  varchar2
  ,p_attribute20                   in  varchar2
  ,p_information_category          in  varchar2
  ,p_information1                  in  varchar2
  ,p_information2                  in  varchar2
  ,p_information3                  in  varchar2
  ,p_information4                  in  varchar2
  ,p_information5                  in  varchar2
  ,p_information6                  in  varchar2
  ,p_information7                  in  varchar2
  ,p_information8                  in  varchar2
  ,p_information9                  in  varchar2
  ,p_information10                 in  varchar2
  ,p_information11                 in  varchar2
  ,p_information12                 in  varchar2
  ,p_information13                 in  varchar2
  ,p_information14                 in  varchar2
  ,p_information15                 in  varchar2
  ,p_information16                 in  varchar2
  ,p_information17                 in  varchar2
  ,p_information18                 in  varchar2
  ,p_information19                 in  varchar2
  ,p_information20                 in  varchar2
  ,p_user_role                     in  varchar2
  ,p_assignment_status_type_id     in  number
  ,p_advance_pay                   in  varchar2
  ,p_absence_overlap_flag          in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_absence_type_a >------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_absence_type_a
  (p_language_code                 in  varchar2
  ,p_business_group_id             in  number
  ,p_input_value_id                in  number
  ,p_date_effective                in  date
  ,p_date_end                      in  date
  ,p_name                          in  varchar2
  ,p_absence_category              in  varchar2
  ,p_comments                      in  varchar2
  ,p_hours_or_days                 in  varchar2
  ,p_inc_or_dec_flag               in  varchar2
  ,p_attribute_category            in  varchar2
  ,p_attribute1                    in  varchar2
  ,p_attribute2                    in  varchar2
  ,p_attribute3                    in  varchar2
  ,p_attribute4                    in  varchar2
  ,p_attribute5                    in  varchar2
  ,p_attribute6                    in  varchar2
  ,p_attribute7                    in  varchar2
  ,p_attribute8                    in  varchar2
  ,p_attribute9                    in  varchar2
  ,p_attribute10                   in  varchar2
  ,p_attribute11                   in  varchar2
  ,p_attribute12                   in  varchar2
  ,p_attribute13                   in  varchar2
  ,p_attribute14                   in  varchar2
  ,p_attribute15                   in  varchar2
  ,p_attribute16                   in  varchar2
  ,p_attribute17                   in  varchar2
  ,p_attribute18                   in  varchar2
  ,p_attribute19                   in  varchar2
  ,p_attribute20                   in  varchar2
  ,p_information_category          in  varchar2
  ,p_information1                  in  varchar2
  ,p_information2                  in  varchar2
  ,p_information3                  in  varchar2
  ,p_information4                  in  varchar2
  ,p_information5                  in  varchar2
  ,p_information6                  in  varchar2
  ,p_information7                  in  varchar2
  ,p_information8                  in  varchar2
  ,p_information9                  in  varchar2
  ,p_information10                 in  varchar2
  ,p_information11                 in  varchar2
  ,p_information12                 in  varchar2
  ,p_information13                 in  varchar2
  ,p_information14                 in  varchar2
  ,p_information15                 in  varchar2
  ,p_information16                 in  varchar2
  ,p_information17                 in  varchar2
  ,p_information18                 in  varchar2
  ,p_information19                 in  varchar2
  ,p_information20                 in  varchar2
  ,p_user_role                     in  varchar2
  ,p_assignment_status_type_id     in  number
  ,p_advance_pay                   in  varchar2
  ,p_absence_overlap_flag          in  varchar2
  ,p_absence_attendance_type_id    in  number
  ,p_object_version_number         in  number
  );
--
end hr_absence_type_bk1;

/
