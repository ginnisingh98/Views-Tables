--------------------------------------------------------
--  DDL for Package PAY_AIF_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_AIF_RKD" AUTHID CURRENT_USER as
/* $Header: pyaifrhi.pkh 120.1 2007/03/30 05:34:02 ttagawa noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_action_information_id        in number
  ,p_action_context_id_o          in number
  ,p_action_context_type_o        in varchar2
  ,p_tax_unit_id_o                in number
  ,p_jurisdiction_code_o          in varchar2
  ,p_source_id_o                  in number
  ,p_source_text_o                in varchar2
  ,p_tax_group_o                  in varchar2
  ,p_object_version_number_o      in number
  ,p_effective_date_o             in date
  ,p_assignment_id_o              in  number
  ,p_action_information_categor_o in varchar2
  ,p_action_information1_o        in varchar2
  ,p_action_information2_o        in varchar2
  ,p_action_information3_o        in varchar2
  ,p_action_information4_o        in varchar2
  ,p_action_information5_o        in varchar2
  ,p_action_information6_o        in varchar2
  ,p_action_information7_o        in varchar2
  ,p_action_information8_o        in varchar2
  ,p_action_information9_o        in varchar2
  ,p_action_information10_o       in varchar2
  ,p_action_information11_o       in varchar2
  ,p_action_information12_o       in varchar2
  ,p_action_information13_o       in varchar2
  ,p_action_information14_o       in varchar2
  ,p_action_information15_o       in varchar2
  ,p_action_information16_o       in varchar2
  ,p_action_information17_o       in varchar2
  ,p_action_information18_o       in varchar2
  ,p_action_information19_o       in varchar2
  ,p_action_information20_o       in varchar2
  ,p_action_information21_o       in varchar2
  ,p_action_information22_o       in varchar2
  ,p_action_information23_o       in varchar2
  ,p_action_information24_o       in varchar2
  ,p_action_information25_o       in varchar2
  ,p_action_information26_o       in varchar2
  ,p_action_information27_o       in varchar2
  ,p_action_information28_o       in varchar2
  ,p_action_information29_o       in varchar2
  ,p_action_information30_o       in varchar2
  );
--
end pay_aif_rkd;

/
