--------------------------------------------------------
--  DDL for Package PER_PJO_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PJO_RKD" AUTHID CURRENT_USER as
/* $Header: pepjorhi.pkh 120.0.12010000.2 2008/08/06 09:28:32 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_previous_job_id              in number
  ,p_previous_employer_id_o       in number
  ,p_start_date_o                 in date
  ,p_end_date_o                   in date
  ,p_period_years_o               in number
  ,p_period_days_o                in number
  ,p_job_name_o                   in varchar2
  ,p_employment_category_o        in varchar2
  ,p_description_o                in varchar2
  ,p_pjo_attribute_category_o     in varchar2
  ,p_pjo_attribute1_o             in varchar2
  ,p_pjo_attribute2_o             in varchar2
  ,p_pjo_attribute3_o             in varchar2
  ,p_pjo_attribute4_o             in varchar2
  ,p_pjo_attribute5_o             in varchar2
  ,p_pjo_attribute6_o             in varchar2
  ,p_pjo_attribute7_o             in varchar2
  ,p_pjo_attribute8_o             in varchar2
  ,p_pjo_attribute9_o             in varchar2
  ,p_pjo_attribute10_o            in varchar2
  ,p_pjo_attribute11_o            in varchar2
  ,p_pjo_attribute12_o            in varchar2
  ,p_pjo_attribute13_o            in varchar2
  ,p_pjo_attribute14_o            in varchar2
  ,p_pjo_attribute15_o            in varchar2
  ,p_pjo_attribute16_o            in varchar2
  ,p_pjo_attribute17_o            in varchar2
  ,p_pjo_attribute18_o            in varchar2
  ,p_pjo_attribute19_o            in varchar2
  ,p_pjo_attribute20_o            in varchar2
  ,p_pjo_attribute21_o            in varchar2
  ,p_pjo_attribute22_o            in varchar2
  ,p_pjo_attribute23_o            in varchar2
  ,p_pjo_attribute24_o            in varchar2
  ,p_pjo_attribute25_o            in varchar2
  ,p_pjo_attribute26_o            in varchar2
  ,p_pjo_attribute27_o            in varchar2
  ,p_pjo_attribute28_o            in varchar2
  ,p_pjo_attribute29_o            in varchar2
  ,p_pjo_attribute30_o            in varchar2
  ,p_pjo_information_category_o   in varchar2
  ,p_pjo_information1_o           in varchar2
  ,p_pjo_information2_o           in varchar2
  ,p_pjo_information3_o           in varchar2
  ,p_pjo_information4_o           in varchar2
  ,p_pjo_information5_o           in varchar2
  ,p_pjo_information6_o           in varchar2
  ,p_pjo_information7_o           in varchar2
  ,p_pjo_information8_o           in varchar2
  ,p_pjo_information9_o           in varchar2
  ,p_pjo_information10_o          in varchar2
  ,p_pjo_information11_o          in varchar2
  ,p_pjo_information12_o          in varchar2
  ,p_pjo_information13_o          in varchar2
  ,p_pjo_information14_o          in varchar2
  ,p_pjo_information15_o          in varchar2
  ,p_pjo_information16_o          in varchar2
  ,p_pjo_information17_o          in varchar2
  ,p_pjo_information18_o          in varchar2
  ,p_pjo_information19_o          in varchar2
  ,p_pjo_information20_o          in varchar2
  ,p_pjo_information21_o          in varchar2
  ,p_pjo_information22_o          in varchar2
  ,p_pjo_information23_o          in varchar2
  ,p_pjo_information24_o          in varchar2
  ,p_pjo_information25_o          in varchar2
  ,p_pjo_information26_o          in varchar2
  ,p_pjo_information27_o          in varchar2
  ,p_pjo_information28_o          in varchar2
  ,p_pjo_information29_o          in varchar2
  ,p_pjo_information30_o          in varchar2
  ,p_object_version_number_o      in number
  ,p_all_assignments_o            in varchar2
  ,p_period_months_o              in number
  );
--
end per_pjo_rkd;

/
