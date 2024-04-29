--------------------------------------------------------
--  DDL for Package OTA_TPC_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_TPC_RKD" AUTHID CURRENT_USER as
/* $Header: ottpcrhi.pkh 120.0 2005/05/29 07:47:09 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_training_plan_cost_id        in number
  ,p_tp_measurement_type_id_o     in number
  ,p_training_plan_id_o           in number
  ,p_booking_id_o                 in number
  ,p_event_id_o                   in number
  ,p_amount_o                     in number
  ,p_currency_code_o              in varchar2
  ,p_business_group_id_o          in number
  ,p_object_version_number_o      in number
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
  ,p_information_category_o       in varchar2
  ,p_tp_cost_information1_o       in varchar2
  ,p_tp_cost_information2_o       in varchar2
  ,p_tp_cost_information3_o       in varchar2
  ,p_tp_cost_information4_o       in varchar2
  ,p_tp_cost_information5_o       in varchar2
  ,p_tp_cost_information6_o       in varchar2
  ,p_tp_cost_information7_o       in varchar2
  ,p_tp_cost_information8_o       in varchar2
  ,p_tp_cost_information9_o       in varchar2
  ,p_tp_cost_information10_o      in varchar2
  ,p_tp_cost_information11_o      in varchar2
  ,p_tp_cost_information12_o      in varchar2
  ,p_tp_cost_information13_o      in varchar2
  ,p_tp_cost_information14_o      in varchar2
  ,p_tp_cost_information15_o      in varchar2
  ,p_tp_cost_information16_o      in varchar2
  ,p_tp_cost_information17_o      in varchar2
  ,p_tp_cost_information18_o      in varchar2
  ,p_tp_cost_information19_o      in varchar2
  ,p_tp_cost_information20_o      in varchar2
  ,p_tp_cost_information21_o      in varchar2
  ,p_tp_cost_information22_o      in varchar2
  ,p_tp_cost_information23_o      in varchar2
  ,p_tp_cost_information24_o      in varchar2
  ,p_tp_cost_information25_o      in varchar2
  ,p_tp_cost_information26_o      in varchar2
  ,p_tp_cost_information27_o      in varchar2
  ,p_tp_cost_information28_o      in varchar2
  ,p_tp_cost_information29_o      in varchar2
  ,p_tp_cost_information30_o      in varchar2
  );
--
end ota_tpc_rkd;

 

/
