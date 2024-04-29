--------------------------------------------------------
--  DDL for Package PER_PSP_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PSP_RKU" AUTHID CURRENT_USER as
/* $Header: pepsprhi.pkh 120.0 2005/05/31 15:29:55 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_effective_date               in date
  ,p_spinal_point_id              in number
  ,p_business_group_id            in number
  ,p_parent_spine_id              in number
  ,p_sequence                     in number
  ,p_spinal_point                 in varchar2
  ,p_request_id                   in number
  ,p_program_application_id       in number
  ,p_program_id                   in number
  ,p_program_update_date          in date
  ,p_object_version_number        in number
  ,p_information_category           in varchar2
  ,p_information1                   in varchar2
  ,p_information2                   in varchar2
  ,p_information3                   in varchar2
  ,p_information4                   in varchar2
  ,p_information5                   in varchar2
  ,p_information6                   in varchar2
  ,p_information7                   in varchar2
  ,p_information8                   in varchar2
  ,p_information9                   in varchar2
  ,p_information10                  in varchar2
  ,p_information11                  in varchar2
  ,p_information12                  in varchar2
  ,p_information13                  in varchar2
  ,p_information14                  in varchar2
  ,p_information15                  in varchar2
  ,p_information16                  in varchar2
  ,p_information17                  in varchar2
  ,p_information18                  in varchar2
  ,p_information19                  in varchar2
  ,p_information20                  in varchar2
  ,p_information21                  in varchar2
  ,p_information22                  in varchar2
  ,p_information23                  in varchar2
  ,p_information24                  in varchar2
  ,p_information25                  in varchar2
  ,p_information26                  in varchar2
  ,p_information27                  in varchar2
  ,p_information28                  in varchar2
  ,p_information29                  in varchar2
  ,p_information30                  in varchar2
  ,p_business_group_id_o          in number
  ,p_parent_spine_id_o            in number
  ,p_sequence_o                   in number
  ,p_spinal_point_o               in varchar2
  ,p_request_id_o                 in number
  ,p_program_application_id_o     in number
  ,p_program_id_o                 in number
  ,p_program_update_date_o        in date
  ,p_object_version_number_o      in number
  ,p_information_category_o         in varchar2
  ,p_information1_o                 in varchar2
  ,p_information2_o                 in varchar2
  ,p_information3_o                 in varchar2
  ,p_information4_o                 in varchar2
  ,p_information5_o                 in varchar2
  ,p_information6_o                 in varchar2
  ,p_information7_o                 in varchar2
  ,p_information8_o                 in varchar2
  ,p_information9_o                 in varchar2
  ,p_information10_o                in varchar2
  ,p_information11_o                in varchar2
  ,p_information12_o                in varchar2
  ,p_information13_o                in varchar2
  ,p_information14_o                in varchar2
  ,p_information15_o                in varchar2
  ,p_information16_o                in varchar2
  ,p_information17_o                in varchar2
  ,p_information18_o                in varchar2
  ,p_information19_o                in varchar2
  ,p_information20_o                in varchar2
  ,p_information21_o                in varchar2
  ,p_information22_o                in varchar2
  ,p_information23_o                in varchar2
  ,p_information24_o                in varchar2
  ,p_information25_o                in varchar2
  ,p_information26_o                in varchar2
  ,p_information27_o                in varchar2
  ,p_information28_o                in varchar2
  ,p_information29_o                in varchar2
  ,p_information30_o                in varchar2
  );
--
end per_psp_rku;

 

/