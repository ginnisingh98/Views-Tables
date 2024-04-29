--------------------------------------------------------
--  DDL for Package HR_LIP_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_LIP_RKD" AUTHID CURRENT_USER as
/* $Header: hrliprhi.pkh 120.0 2005/05/31 01:17:20 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_effective_date               in date
  ,p_datetrack_mode               in varchar2
  ,p_validation_start_date        in date
  ,p_validation_end_date          in date
  ,p_liability_premiums_id        in number
  ,p_effective_start_date         in date
  ,p_effective_end_date           in date
  ,p_organization_link_id_o       in number
  ,p_effective_start_date_o       in date
  ,p_effective_end_date_o         in date
  ,p_std_percentage_o             in number
  ,p_calculation_method_o         in varchar2
  ,p_std_working_hours_per_year_o in number
  ,p_max_remuneration_o           in number
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
  ,p_object_version_number_o      in number
  );
--
end hr_lip_rkd;

 

/
