--------------------------------------------------------
--  DDL for Package PQP_VAI_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_VAI_RKD" AUTHID CURRENT_USER as
/* $Header: pqvairhi.pkh 120.0.12010000.2 2008/08/08 07:19:40 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_veh_alloc_extra_info_id      in number
  ,p_vehicle_allocation_id_o      in number
  ,p_information_type_o           in varchar2
  ,p_vaei_attribute_category_o    in varchar2
  ,p_vaei_attribute1_o            in varchar2
  ,p_vaei_attribute2_o            in varchar2
  ,p_vaei_attribute3_o            in varchar2
  ,p_vaei_attribute4_o            in varchar2
  ,p_vaei_attribute5_o            in varchar2
  ,p_vaei_attribute6_o            in varchar2
  ,p_vaei_attribute7_o            in varchar2
  ,p_vaei_attribute8_o            in varchar2
  ,p_vaei_attribute9_o            in varchar2
  ,p_vaei_attribute10_o           in varchar2
  ,p_vaei_attribute11_o           in varchar2
  ,p_vaei_attribute12_o           in varchar2
  ,p_vaei_attribute13_o           in varchar2
  ,p_vaei_attribute14_o           in varchar2
  ,p_vaei_attribute15_o           in varchar2
  ,p_vaei_attribute16_o           in varchar2
  ,p_vaei_attribute17_o           in varchar2
  ,p_vaei_attribute18_o           in varchar2
  ,p_vaei_attribute19_o           in varchar2
  ,p_vaei_attribute20_o           in varchar2
  ,p_vaei_information_category_o  in varchar2
  ,p_vaei_information1_o          in varchar2
  ,p_vaei_information2_o          in varchar2
  ,p_vaei_information3_o          in varchar2
  ,p_vaei_information4_o          in varchar2
  ,p_vaei_information5_o          in varchar2
  ,p_vaei_information6_o          in varchar2
  ,p_vaei_information7_o          in varchar2
  ,p_vaei_information8_o          in varchar2
  ,p_vaei_information9_o          in varchar2
  ,p_vaei_information10_o         in varchar2
  ,p_vaei_information11_o         in varchar2
  ,p_vaei_information12_o         in varchar2
  ,p_vaei_information13_o         in varchar2
  ,p_vaei_information14_o         in varchar2
  ,p_vaei_information15_o         in varchar2
  ,p_vaei_information16_o         in varchar2
  ,p_vaei_information17_o         in varchar2
  ,p_vaei_information18_o         in varchar2
  ,p_vaei_information19_o         in varchar2
  ,p_vaei_information20_o         in varchar2
  ,p_vaei_information21_o         in varchar2
  ,p_vaei_information22_o         in varchar2
  ,p_vaei_information23_o         in varchar2
  ,p_vaei_information24_o         in varchar2
  ,p_vaei_information25_o         in varchar2
  ,p_vaei_information26_o         in varchar2
  ,p_vaei_information27_o         in varchar2
  ,p_vaei_information28_o         in varchar2
  ,p_vaei_information29_o         in varchar2
  ,p_vaei_information30_o         in varchar2
  ,p_object_version_number_o      in number
  ,p_request_id_o                 in number
  ,p_program_application_id_o     in number
  ,p_program_id_o                 in number
  ,p_program_update_date_o        in date
  );
--
end pqp_vai_rkd;

/
