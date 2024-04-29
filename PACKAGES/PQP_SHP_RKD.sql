--------------------------------------------------------
--  DDL for Package PQP_SHP_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_SHP_RKD" AUTHID CURRENT_USER as
/* $Header: pqshprhi.pkh 120.0.12010000.1 2008/07/28 11:23:18 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_service_history_period_id    in number
  ,p_business_group_id_o          in number
  ,p_assignment_id_o              in number
  ,p_start_date_o                 in date
  ,p_end_date_o                   in date
  ,p_employer_name_o              in varchar2
  ,p_employer_address_o           in varchar2
  ,p_employer_type_o              in varchar2
  ,p_employer_subtype_o           in varchar2
  ,p_period_years_o               in number
  ,p_period_days_o                in number
  ,p_description_o                in varchar2
  ,p_continuous_service_o         in varchar2
  ,p_all_assignments_o            in varchar2
  ,p_object_version_number_o      in number
  ,p_shp_attribute_category_o     in varchar2
  ,p_shp_attribute1_o             in varchar2
  ,p_shp_attribute2_o             in varchar2
  ,p_shp_attribute3_o             in varchar2
  ,p_shp_attribute4_o             in varchar2
  ,p_shp_attribute5_o             in varchar2
  ,p_shp_attribute6_o             in varchar2
  ,p_shp_attribute7_o             in varchar2
  ,p_shp_attribute8_o             in varchar2
  ,p_shp_attribute9_o             in varchar2
  ,p_shp_attribute10_o            in varchar2
  ,p_shp_attribute11_o            in varchar2
  ,p_shp_attribute12_o            in varchar2
  ,p_shp_attribute13_o            in varchar2
  ,p_shp_attribute14_o            in varchar2
  ,p_shp_attribute15_o            in varchar2
  ,p_shp_attribute16_o            in varchar2
  ,p_shp_attribute17_o            in varchar2
  ,p_shp_attribute18_o            in varchar2
  ,p_shp_attribute19_o            in varchar2
  ,p_shp_attribute20_o            in varchar2
  ,p_shp_information_category_o   in varchar2
  ,p_shp_information1_o           in varchar2
  ,p_shp_information2_o           in varchar2
  ,p_shp_information3_o           in varchar2
  ,p_shp_information4_o           in varchar2
  ,p_shp_information5_o           in varchar2
  ,p_shp_information6_o           in varchar2
  ,p_shp_information7_o           in varchar2
  ,p_shp_information8_o           in varchar2
  ,p_shp_information9_o           in varchar2
  ,p_shp_information10_o          in varchar2
  ,p_shp_information11_o          in varchar2
  ,p_shp_information12_o          in varchar2
  ,p_shp_information13_o          in varchar2
  ,p_shp_information14_o          in varchar2
  ,p_shp_information15_o          in varchar2
  ,p_shp_information16_o          in varchar2
  ,p_shp_information17_o          in varchar2
  ,p_shp_information18_o          in varchar2
  ,p_shp_information19_o          in varchar2
  ,p_shp_information20_o          in varchar2
  );
--
end pqp_shp_rkd;

/
