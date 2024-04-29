--------------------------------------------------------
--  DDL for Package IRC_ISC_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_ISC_RKD" AUTHID CURRENT_USER as
/* $Header: iriscrhi.pkh 120.0 2005/07/26 15:11:23 mbocutt noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_search_criteria_id           in number
  ,p_object_id_o                  in number
  ,p_object_type_o                in varchar2
  ,p_search_name_o                in varchar2
  ,p_search_type_o                in varchar2
  ,p_location_o                   in varchar2
  ,p_distance_to_location_o       in varchar2
  ,p_geocode_location_o           in varchar2
  ,p_geocode_country_o            in varchar2
  ,p_derived_location_o           in varchar2
  ,p_location_id_o                in number
  ,p_longitude_o                  in number
  ,p_latitude_o                   in number
  ,p_employee_o                   in varchar2
  ,p_contractor_o                 in varchar2
  ,p_employment_category_o        in varchar2
  ,p_keywords_o                   in varchar2
  ,p_travel_percentage_o          in number
  ,p_min_salary_o                 in number
  ,p_max_salary_o                 in number
  ,p_salary_currency_o            in varchar2
  ,p_salary_period_o              in varchar2
  ,p_match_competence_o           in varchar2
  ,p_match_qualification_o        in varchar2
  ,p_job_title_o                  in varchar2
  ,p_department_o                 in varchar2
  ,p_professional_area_o          in varchar2
  ,p_work_at_home_o               in varchar2
  ,p_min_qual_level_o             in number
  ,p_max_qual_level_o             in number
  ,p_use_for_matching_o           in varchar2
  ,p_description_o                in varchar2
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
  ,p_isc_information_category_o   in varchar2
  ,p_isc_information1_o           in varchar2
  ,p_isc_information2_o           in varchar2
  ,p_isc_information3_o           in varchar2
  ,p_isc_information4_o           in varchar2
  ,p_isc_information5_o           in varchar2
  ,p_isc_information6_o           in varchar2
  ,p_isc_information7_o           in varchar2
  ,p_isc_information8_o           in varchar2
  ,p_isc_information9_o           in varchar2
  ,p_isc_information10_o          in varchar2
  ,p_isc_information11_o          in varchar2
  ,p_isc_information12_o          in varchar2
  ,p_isc_information13_o          in varchar2
  ,p_isc_information14_o          in varchar2
  ,p_isc_information15_o          in varchar2
  ,p_isc_information16_o          in varchar2
  ,p_isc_information17_o          in varchar2
  ,p_isc_information18_o          in varchar2
  ,p_isc_information19_o          in varchar2
  ,p_isc_information20_o          in varchar2
  ,p_isc_information21_o          in varchar2
  ,p_isc_information22_o          in varchar2
  ,p_isc_information23_o          in varchar2
  ,p_isc_information24_o          in varchar2
  ,p_isc_information25_o          in varchar2
  ,p_isc_information26_o          in varchar2
  ,p_isc_information27_o          in varchar2
  ,p_isc_information28_o          in varchar2
  ,p_isc_information29_o          in varchar2
  ,p_isc_information30_o          in varchar2
  ,p_object_version_number_o      in number
  ,p_date_posted_o                in varchar2
  );
--
end irc_isc_rkd;

 

/
