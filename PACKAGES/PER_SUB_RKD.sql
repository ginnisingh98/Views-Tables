--------------------------------------------------------
--  DDL for Package PER_SUB_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_SUB_RKD" AUTHID CURRENT_USER as
/* $Header: pesubrhi.pkh 120.0 2005/05/31 22:09:52 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_delete >-----------------------------|
-- ----------------------------------------------------------------------------
--
Procedure after_delete
  (
  p_subjects_taken_id            in number,
  p_start_date_o                 in date,
  p_major_o                      in varchar2,
  p_subject_status_o             in varchar2,
  p_subject_o                    in varchar2,
  p_grade_attained_o             in varchar2,
  p_end_date_o                   in date,
  p_qualification_id_o           in number,
  p_object_version_number_o      in number,
  p_attribute_category_o         in varchar2,
  p_attribute1_o                 in varchar2,
  p_attribute2_o                 in varchar2,
  p_attribute3_o                 in varchar2,
  p_attribute4_o                 in varchar2,
  p_attribute5_o                 in varchar2,
  p_attribute6_o                 in varchar2,
  p_attribute7_o                 in varchar2,
  p_attribute8_o                 in varchar2,
  p_attribute9_o                 in varchar2,
  p_attribute10_o                in varchar2,
  p_attribute11_o                in varchar2,
  p_attribute12_o                in varchar2,
  p_attribute13_o                in varchar2,
  p_attribute14_o                in varchar2,
  p_attribute15_o                in varchar2,
  p_attribute16_o                in varchar2,
  p_attribute17_o                in varchar2,
  p_attribute18_o                in varchar2,
  p_attribute19_o                in varchar2,
  p_attribute20_o                in varchar2,
  p_sub_information_category_o            in varchar2,
p_sub_information1_o                    in varchar2,
p_sub_information2_o                    in varchar2,
p_sub_information3_o                    in varchar2,
p_sub_information4_o                    in varchar2,
p_sub_information5_o                    in varchar2,
p_sub_information6_o                    in varchar2,
p_sub_information7_o                    in varchar2,
p_sub_information8_o                    in varchar2,
p_sub_information9_o                    in varchar2,
p_sub_information10_o                   in varchar2,
p_sub_information11_o                   in varchar2,
p_sub_information12_o                   in varchar2,
p_sub_information13_o                   in varchar2,
p_sub_information14_o                   in varchar2,
p_sub_information15_o                   in varchar2,
p_sub_information16_o                   in varchar2,
p_sub_information17_o                   in varchar2,
p_sub_information18_o                   in varchar2,
p_sub_information19_o                   in varchar2,
p_sub_information20_o                   in varchar2
  );
end per_sub_rkd;

 

/
