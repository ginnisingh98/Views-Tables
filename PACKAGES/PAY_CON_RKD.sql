--------------------------------------------------------
--  DDL for Package PAY_CON_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CON_RKD" AUTHID CURRENT_USER as
/* $Header: pyconrhi.pkh 115.1 99/09/30 13:47:46 porting ship  $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_contr_history_id               in number
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
end pay_con_rkd;

 

/
