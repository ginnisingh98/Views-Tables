--------------------------------------------------------
--  DDL for Package PER_ELC_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ELC_RKD" AUTHID CURRENT_USER as
/* $Header: peelcrhi.pkh 120.0 2005/05/31 07:56:59 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_election_id                  in number
  ,p_business_group_id_o          in number
  ,p_election_date_o              in date
  ,p_description_o                in varchar2
  ,p_rep_body_id_o                in number
  ,p_previous_election_date_o     in date
  ,p_next_election_date_o         in date
  ,p_result_publish_date_o        in date
  ,p_attribute_category_o         in varchar2
  ,p_attribute1_o                 in varchar2
  ,p_attribute2_o                 in varchar2
  ,p_attribute3_o                 in varchar2
  ,p_attribute4_o                 in varchar2
  ,p_attribute5_o                 in varchar2
  ,p_attribute6_o                 in varchar2
  ,p_attribute7_o                 in varchar2
  ,p_attribute8_o                 in varchar2
  ,p_attribute9_o                 in varchar2
  ,p_attribute10_o                in varchar2
  ,p_attribute11_o                in varchar2
  ,p_attribute12_o                in varchar2
  ,p_attribute13_o                in varchar2
  ,p_attribute14_o                in varchar2
  ,p_attribute15_o                in varchar2
  ,p_attribute16_o                in varchar2
  ,p_attribute17_o                in varchar2
  ,p_attribute18_o                in varchar2
  ,p_attribute19_o                in varchar2
  ,p_attribute20_o                in varchar2
  ,p_attribute21_o                in varchar2
  ,p_attribute22_o                in varchar2
  ,p_attribute23_o                in varchar2
  ,p_attribute24_o                in varchar2
  ,p_attribute25_o                in varchar2
  ,p_attribute26_o                in varchar2
  ,p_attribute27_o                in varchar2
  ,p_attribute28_o                in varchar2
  ,p_attribute29_o                in varchar2
  ,p_attribute30_o                in varchar2
  ,p_election_info_category_o     in varchar2
  ,p_election_information1_o      in varchar2
  ,p_election_information2_o      in varchar2
  ,p_election_information3_o      in varchar2
  ,p_election_information4_o      in varchar2
  ,p_election_information5_o      in varchar2
  ,p_election_information6_o      in varchar2
  ,p_election_information7_o      in varchar2
  ,p_election_information8_o      in varchar2
  ,p_election_information9_o      in varchar2
  ,p_election_information10_o     in varchar2
  ,p_election_information11_o     in varchar2
  ,p_election_information12_o     in varchar2
  ,p_election_information13_o     in varchar2
  ,p_election_information14_o     in varchar2
  ,p_election_information15_o     in varchar2
  ,p_election_information16_o     in varchar2
  ,p_election_information17_o     in varchar2
  ,p_election_information18_o     in varchar2
  ,p_election_information19_o     in varchar2
  ,p_election_information20_o     in varchar2
  ,p_election_information21_o     in varchar2
  ,p_election_information22_o     in varchar2
  ,p_election_information23_o     in varchar2
  ,p_election_information24_o     in varchar2
  ,p_election_information25_o     in varchar2
  ,p_election_information26_o     in varchar2
  ,p_election_information27_o     in varchar2
  ,p_election_information28_o     in varchar2
  ,p_election_information29_o     in varchar2
  ,p_election_information30_o     in varchar2
  ,p_object_version_number_o      in number
  );
--
end per_elc_rkd;

 

/
