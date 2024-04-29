--------------------------------------------------------
--  DDL for Package PER_SUB_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_SUB_RKI" AUTHID CURRENT_USER as
/* $Header: pesubrhi.pkh 120.0 2005/05/31 22:09:52 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
Procedure after_insert
  (
  p_subjects_taken_id            in number,
  p_start_date                   in date,
  p_major                        in varchar2,
  p_subject_status               in varchar2,
  p_subject                      in varchar2,
  p_grade_attained               in varchar2,
  p_end_date                     in date,
  p_qualification_id             in number,
  p_object_version_number        in number,
  p_attribute_category           in varchar2,
  p_attribute1                   in varchar2,
  p_attribute2                   in varchar2,
  p_attribute3                   in varchar2,
  p_attribute4                   in varchar2,
  p_attribute5                   in varchar2,
  p_attribute6                   in varchar2,
  p_attribute7                   in varchar2,
  p_attribute8                   in varchar2,
  p_attribute9                   in varchar2,
  p_attribute10                  in varchar2,
  p_attribute11                  in varchar2,
  p_attribute12                  in varchar2,
  p_attribute13                  in varchar2,
  p_attribute14                  in varchar2,
  p_attribute15                  in varchar2,
  p_attribute16                  in varchar2,
  p_attribute17                  in varchar2,
  p_attribute18                  in varchar2,
  p_attribute19                  in varchar2,
  p_attribute20                  in varchar2,
  p_effective_date               in date,
  p_sub_information_category            in varchar2,
  p_sub_information1                    in varchar2,
  p_sub_information2                    in varchar2,
  p_sub_information3                    in varchar2,
  p_sub_information4                    in varchar2,
  p_sub_information5                    in varchar2,
  p_sub_information6                    in varchar2,
  p_sub_information7                    in varchar2,
  p_sub_information8                    in varchar2,
  p_sub_information9                    in varchar2,
  p_sub_information10                   in varchar2,
  p_sub_information11                   in varchar2,
  p_sub_information12                   in varchar2,
  p_sub_information13                   in varchar2,
  p_sub_information14                   in varchar2,
  p_sub_information15                   in varchar2,
  p_sub_information16                   in varchar2,
  p_sub_information17                   in varchar2,
  p_sub_information18                   in varchar2,
  p_sub_information19                   in varchar2,
  p_sub_information20                   in varchar2
  );
end per_sub_rki;

 

/
