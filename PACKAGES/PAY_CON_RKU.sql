--------------------------------------------------------
--  DDL for Package PAY_CON_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CON_RKU" AUTHID CURRENT_USER as
/* $Header: pyconrhi.pkh 115.1 99/09/30 13:47:46 porting ship  $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_contr_history_id               in number
 ,p_person_id                      in number
 ,p_date_from                      in date
 ,p_date_to                        in date
 ,p_contr_type                     in varchar2
 ,p_business_group_id              in number
 ,p_legislation_code               in varchar2
 ,p_amt_contr                      in number
 ,p_max_contr_allowed              in number
 ,p_includable_comp                in number
 ,p_tax_unit_id                    in number
 ,p_source_system                  in varchar2
 ,p_contr_information_category     in varchar2
 ,p_contr_information1             in varchar2
 ,p_contr_information2             in varchar2
 ,p_contr_information3             in varchar2
 ,p_contr_information4             in varchar2
 ,p_contr_information5             in varchar2
 ,p_contr_information6             in varchar2
 ,p_contr_information7             in varchar2
 ,p_contr_information8             in varchar2
 ,p_contr_information9             in varchar2
 ,p_contr_information10            in varchar2
 ,p_contr_information11            in varchar2
 ,p_contr_information12            in varchar2
 ,p_contr_information13            in varchar2
 ,p_contr_information14            in varchar2
 ,p_contr_information15            in varchar2
 ,p_contr_information16            in varchar2
 ,p_contr_information17            in varchar2
 ,p_contr_information18            in varchar2
 ,p_contr_information19            in varchar2
 ,p_contr_information20            in varchar2
 ,p_contr_information21            in varchar2
 ,p_contr_information22            in varchar2
 ,p_contr_information23            in varchar2
 ,p_contr_information24            in varchar2
 ,p_contr_information25            in varchar2
 ,p_contr_information26            in varchar2
 ,p_contr_information27            in varchar2
 ,p_contr_information28            in varchar2
 ,p_contr_information29            in varchar2
 ,p_contr_information30            in varchar2
 ,p_object_version_number          in number
 ,p_person_id_o                    in number
 ,p_date_from_o                    in date
 ,p_date_to_o                      in date
 ,p_contr_type_o                   in varchar2
 ,p_business_group_id_o            in number
 ,p_legislation_code_o             in varchar2
 ,p_amt_contr_o                    in number
 ,p_max_contr_allowed_o            in number
 ,p_includable_comp_o              in number
 ,p_tax_unit_id_o                  in number
 ,p_source_system_o                in varchar2
 ,p_contr_information_category_o   in varchar2
 ,p_contr_information1_o           in varchar2
 ,p_contr_information2_o           in varchar2
 ,p_contr_information3_o           in varchar2
 ,p_contr_information4_o           in varchar2
 ,p_contr_information5_o           in varchar2
 ,p_contr_information6_o           in varchar2
 ,p_contr_information7_o           in varchar2
 ,p_contr_information8_o           in varchar2
 ,p_contr_information9_o           in varchar2
 ,p_contr_information10_o          in varchar2
 ,p_contr_information11_o          in varchar2
 ,p_contr_information12_o          in varchar2
 ,p_contr_information13_o          in varchar2
 ,p_contr_information14_o          in varchar2
 ,p_contr_information15_o          in varchar2
 ,p_contr_information16_o          in varchar2
 ,p_contr_information17_o          in varchar2
 ,p_contr_information18_o          in varchar2
 ,p_contr_information19_o          in varchar2
 ,p_contr_information20_o          in varchar2
 ,p_contr_information21_o          in varchar2
 ,p_contr_information22_o          in varchar2
 ,p_contr_information23_o          in varchar2
 ,p_contr_information24_o          in varchar2
 ,p_contr_information25_o          in varchar2
 ,p_contr_information26_o          in varchar2
 ,p_contr_information27_o          in varchar2
 ,p_contr_information28_o          in varchar2
 ,p_contr_information29_o          in varchar2
 ,p_contr_information30_o          in varchar2
 ,p_object_version_number_o        in number
  );
--
end pay_con_rku;

 

/
