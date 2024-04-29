--------------------------------------------------------
--  DDL for Package PQP_VRI_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_VRI_RKD" AUTHID CURRENT_USER as
/* $Header: pqvrirhi.pkh 120.0.12010000.2 2008/08/08 07:24:24 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_veh_repos_extra_info_id      in number
  ,p_vehicle_repository_id_o      in number
  ,p_information_type_o           in varchar2
  ,p_vrei_attribute_category_o    in varchar2
  ,p_vrei_attribute1_o            in varchar2
  ,p_vrei_attribute2_o            in varchar2
  ,p_vrei_attribute3_o            in varchar2
  ,p_vrei_attribute4_o            in varchar2
  ,p_vrei_attribute5_o            in varchar2
  ,p_vrei_attribute6_o            in varchar2
  ,p_vrei_attribute7_o            in varchar2
  ,p_vrei_attribute8_o            in varchar2
  ,p_vrei_attribute9_o            in varchar2
  ,p_vrei_attribute10_o           in varchar2
  ,p_vrei_attribute11_o           in varchar2
  ,p_vrei_attribute12_o           in varchar2
  ,p_vrei_attribute13_o           in varchar2
  ,p_vrei_attribute14_o           in varchar2
  ,p_vrei_attribute15_o           in varchar2
  ,p_vrei_attribute16_o           in varchar2
  ,p_vrei_attribute17_o           in varchar2
  ,p_vrei_attribute18_o           in varchar2
  ,p_vrei_attribute19_o           in varchar2
  ,p_vrei_attribute20_o           in varchar2
  ,p_vrei_information_category_o  in varchar2
  ,p_vrei_information1_o          in varchar2
  ,p_vrei_information2_o          in varchar2
  ,p_vrei_information3_o          in varchar2
  ,p_vrei_information4_o          in varchar2
  ,p_vrei_information5_o          in varchar2
  ,p_vrei_information6_o          in varchar2
  ,p_vrei_information7_o          in varchar2
  ,p_vrei_information8_o          in varchar2
  ,p_vrei_information9_o          in varchar2
  ,p_vrei_information10_o         in varchar2
  ,p_vrei_information11_o         in varchar2
  ,p_vrei_information12_o         in varchar2
  ,p_vrei_information13_o         in varchar2
  ,p_vrei_information14_o         in varchar2
  ,p_vrei_information15_o         in varchar2
  ,p_vrei_information16_o         in varchar2
  ,p_vrei_information17_o         in varchar2
  ,p_vrei_information18_o         in varchar2
  ,p_vrei_information19_o         in varchar2
  ,p_vrei_information20_o         in varchar2
  ,p_vrei_information21_o         in varchar2
  ,p_vrei_information22_o         in varchar2
  ,p_vrei_information23_o         in varchar2
  ,p_vrei_information24_o         in varchar2
  ,p_vrei_information25_o         in varchar2
  ,p_vrei_information26_o         in varchar2
  ,p_vrei_information27_o         in varchar2
  ,p_vrei_information28_o         in varchar2
  ,p_vrei_information29_o         in varchar2
  ,p_vrei_information30_o         in varchar2
  ,p_object_version_number_o      in number
  ,p_request_id_o                 in number
  ,p_program_application_id_o     in number
  ,p_program_id_o                 in number
  ,p_program_update_date_o        in date
  );
--
end pqp_vri_rkd;

/
