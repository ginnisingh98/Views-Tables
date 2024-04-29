--------------------------------------------------------
--  DDL for Package PAY_OPM_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_OPM_RKD" AUTHID CURRENT_USER as
/* $Header: pyopmrhi.pkh 120.1 2005/08/30 07:52:36 pgongada noship $ */
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
  ,p_org_payment_method_id        in number
  ,p_effective_start_date         in date
  ,p_effective_end_date           in date
  ,p_effective_start_date_o       in date
  ,p_effective_end_date_o         in date
  ,p_business_group_id_o          in number
  ,p_external_account_id_o        in number
  ,p_currency_code_o              in varchar2
  ,p_payment_type_id_o            in number
  ,p_defined_balance_id_o         in number
  ,p_org_payment_method_name_o    in varchar2
  ,p_comment_id_o                 in number
  ,p_comments_o                   in varchar2
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
  ,p_pmeth_information_category_o in varchar2
  ,p_pmeth_information1_o         in varchar2
  ,p_pmeth_information2_o         in varchar2
  ,p_pmeth_information3_o         in varchar2
  ,p_pmeth_information4_o         in varchar2
  ,p_pmeth_information5_o         in varchar2
  ,p_pmeth_information6_o         in varchar2
  ,p_pmeth_information7_o         in varchar2
  ,p_pmeth_information8_o         in varchar2
  ,p_pmeth_information9_o         in varchar2
  ,p_pmeth_information10_o        in varchar2
  ,p_pmeth_information11_o        in varchar2
  ,p_pmeth_information12_o        in varchar2
  ,p_pmeth_information13_o        in varchar2
  ,p_pmeth_information14_o        in varchar2
  ,p_pmeth_information15_o        in varchar2
  ,p_pmeth_information16_o        in varchar2
  ,p_pmeth_information17_o        in varchar2
  ,p_pmeth_information18_o        in varchar2
  ,p_pmeth_information19_o        in varchar2
  ,p_pmeth_information20_o        in varchar2
  ,p_object_version_number_o      in number
  ,p_transfer_to_gl_flag_o        in varchar2
  ,p_cost_payment_o               in varchar2
  ,p_cost_cleared_payment_o       in varchar2
  ,p_cost_cleared_void_payment_o  in varchar2
  ,p_exclude_manual_payment_o     in varchar2
  );
--
end pay_opm_rkd;

 

/