--------------------------------------------------------
--  DDL for Package PAY_PBC_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PBC_RKU" AUTHID CURRENT_USER as
/* $Header: pypbcrhi.pkh 120.0 2005/05/29 07:19:55 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_effective_date               in date
  ,p_datetrack_mode               in varchar2
  ,p_validation_start_date        in date
  ,p_validation_end_date          in date
  ,p_balance_category_id          in number
  ,p_effective_start_date         in date
  ,p_effective_end_date           in date
  ,p_save_run_balance_enabled     in varchar2
  ,p_user_category_name           in varchar2
  ,p_pbc_information_category     in varchar2
  ,p_pbc_information1             in varchar2
  ,p_pbc_information2             in varchar2
  ,p_pbc_information3             in varchar2
  ,p_pbc_information4             in varchar2
  ,p_pbc_information5             in varchar2
  ,p_pbc_information6             in varchar2
  ,p_pbc_information7             in varchar2
  ,p_pbc_information8             in varchar2
  ,p_pbc_information9             in varchar2
  ,p_pbc_information10            in varchar2
  ,p_pbc_information11            in varchar2
  ,p_pbc_information12            in varchar2
  ,p_pbc_information13            in varchar2
  ,p_pbc_information14            in varchar2
  ,p_pbc_information15            in varchar2
  ,p_pbc_information16            in varchar2
  ,p_pbc_information17            in varchar2
  ,p_pbc_information18            in varchar2
  ,p_pbc_information19            in varchar2
  ,p_pbc_information20            in varchar2
  ,p_pbc_information21            in varchar2
  ,p_pbc_information22            in varchar2
  ,p_pbc_information23            in varchar2
  ,p_pbc_information24            in varchar2
  ,p_pbc_information25            in varchar2
  ,p_pbc_information26            in varchar2
  ,p_pbc_information27            in varchar2
  ,p_pbc_information28            in varchar2
  ,p_pbc_information29            in varchar2
  ,p_pbc_information30            in varchar2
  ,p_object_version_number        in number
  ,p_category_name_o              in varchar2
  ,p_effective_start_date_o       in date
  ,p_effective_end_date_o         in date
  ,p_legislation_code_o           in varchar2
  ,p_business_group_id_o          in number
  ,p_save_run_balance_enabled_o   in varchar2
  ,p_user_category_name_o         in varchar2
  ,p_pbc_information_category_o   in varchar2
  ,p_pbc_information1_o           in varchar2
  ,p_pbc_information2_o           in varchar2
  ,p_pbc_information3_o           in varchar2
  ,p_pbc_information4_o           in varchar2
  ,p_pbc_information5_o           in varchar2
  ,p_pbc_information6_o           in varchar2
  ,p_pbc_information7_o           in varchar2
  ,p_pbc_information8_o           in varchar2
  ,p_pbc_information9_o           in varchar2
  ,p_pbc_information10_o          in varchar2
  ,p_pbc_information11_o          in varchar2
  ,p_pbc_information12_o          in varchar2
  ,p_pbc_information13_o          in varchar2
  ,p_pbc_information14_o          in varchar2
  ,p_pbc_information15_o          in varchar2
  ,p_pbc_information16_o          in varchar2
  ,p_pbc_information17_o          in varchar2
  ,p_pbc_information18_o          in varchar2
  ,p_pbc_information19_o          in varchar2
  ,p_pbc_information20_o          in varchar2
  ,p_pbc_information21_o          in varchar2
  ,p_pbc_information22_o          in varchar2
  ,p_pbc_information23_o          in varchar2
  ,p_pbc_information24_o          in varchar2
  ,p_pbc_information25_o          in varchar2
  ,p_pbc_information26_o          in varchar2
  ,p_pbc_information27_o          in varchar2
  ,p_pbc_information28_o          in varchar2
  ,p_pbc_information29_o          in varchar2
  ,p_pbc_information30_o          in varchar2
  ,p_object_version_number_o      in number
  );
--
end pay_pbc_rku;

 

/
