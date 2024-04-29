--------------------------------------------------------
--  DDL for Package PAY_PPM_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PPM_RKD" AUTHID CURRENT_USER as
/* $Header: pyppmrhi.pkh 120.0.12010000.2 2008/12/05 13:44:17 abanand ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_effective_date                 in date
  ,p_datetrack_mode		    in varchar2
  ,p_validation_start_date          in date
  ,p_validation_end_date            in date
  ,p_effective_start_date           in date
  ,p_effective_end_date             in date
  ,p_object_version_number          in number
  ,p_personal_payment_method_id     in number
  ,p_effective_start_date_o         in date
  ,p_effective_end_date_o           in date
  ,p_business_group_id_o            in number
  ,p_external_account_id_o          in number
  ,p_assignment_id_o                in number
  ,p_org_payment_method_id_o        in number
  ,p_amount_o                       in number
  ,p_comment_id_o                   in number
  ,p_percentage_o                   in number
  ,p_priority_o                     in number
  ,p_attribute_category_o           in varchar2
  ,p_attribute1_o                   in varchar2
  ,p_attribute2_o                   in varchar2
  ,p_attribute3_o                   in varchar2
  ,p_attribute4_o                   in varchar2
  ,p_attribute5_o                   in varchar2
  ,p_attribute6_o                   in varchar2
  ,p_attribute7_o                   in varchar2
  ,p_attribute8_o                   in varchar2
  ,p_attribute9_o                   in varchar2
  ,p_attribute10_o                  in varchar2
  ,p_attribute11_o                  in varchar2
  ,p_attribute12_o                  in varchar2
  ,p_attribute13_o                  in varchar2
  ,p_attribute14_o                  in varchar2
  ,p_attribute15_o                  in varchar2
  ,p_attribute16_o                  in varchar2
  ,p_attribute17_o                  in varchar2
  ,p_attribute18_o                  in varchar2
  ,p_attribute19_o                  in varchar2
  ,p_attribute20_o                  in varchar2
  ,p_object_version_number_o        in number
  ,p_payee_type_o                   in varchar2
  ,p_payee_id_o                     in number
  ,p_ppm_information_category_o     in varchar2
  ,p_ppm_information1_o             in varchar2
  ,p_ppm_information2_o             in varchar2
  ,p_ppm_information3_o             in varchar2
  ,p_ppm_information4_o             in varchar2
  ,p_ppm_information5_o             in varchar2
  ,p_ppm_information6_o             in varchar2
  ,p_ppm_information7_o             in varchar2
  ,p_ppm_information8_o             in varchar2
  ,p_ppm_information9_o             in varchar2
  ,p_ppm_information10_o            in varchar2
  ,p_ppm_information11_o            in varchar2
  ,p_ppm_information12_o            in varchar2
  ,p_ppm_information13_o            in varchar2
  ,p_ppm_information14_o            in varchar2
  ,p_ppm_information15_o            in varchar2
  ,p_ppm_information16_o            in varchar2
  ,p_ppm_information17_o            in varchar2
  ,p_ppm_information18_o            in varchar2
  ,p_ppm_information19_o            in varchar2
  ,p_ppm_information20_o            in varchar2
  ,p_ppm_information21_o            in varchar2
  ,p_ppm_information22_o            in varchar2
  ,p_ppm_information23_o            in varchar2
  ,p_ppm_information24_o            in varchar2
  ,p_ppm_information25_o            in varchar2
  ,p_ppm_information26_o            in varchar2
  ,p_ppm_information27_o            in varchar2
  ,p_ppm_information28_o            in varchar2
  ,p_ppm_information29_o            in varchar2
  ,p_ppm_information30_o            in varchar2
  );
--
end pay_ppm_rkd;

/
