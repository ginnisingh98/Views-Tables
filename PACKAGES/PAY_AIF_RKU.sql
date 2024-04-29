--------------------------------------------------------
--  DDL for Package PAY_AIF_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_AIF_RKU" AUTHID CURRENT_USER as
/* $Header: pyaifrhi.pkh 120.1 2007/03/30 05:34:02 ttagawa noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_action_information_id        in number
  ,p_object_version_number        in number
  ,p_action_information1          in varchar2
  ,p_action_information2          in varchar2
  ,p_action_information3          in varchar2
  ,p_action_information4          in varchar2
  ,p_action_information5          in varchar2
  ,p_action_information6          in varchar2
  ,p_action_information7          in varchar2
  ,p_action_information8          in varchar2
  ,p_action_information9          in varchar2
  ,p_action_information10         in varchar2
  ,p_action_information11         in varchar2
  ,p_action_information12         in varchar2
  ,p_action_information13         in varchar2
  ,p_action_information14         in varchar2
  ,p_action_information15         in varchar2
  ,p_action_information16         in varchar2
  ,p_action_information17         in varchar2
  ,p_action_information18         in varchar2
  ,p_action_information19         in varchar2
  ,p_action_information20         in varchar2
  ,p_action_information21         in varchar2
  ,p_action_information22         in varchar2
  ,p_action_information23         in varchar2
  ,p_action_information24         in varchar2
  ,p_action_information25         in varchar2
  ,p_action_information26         in varchar2
  ,p_action_information27         in varchar2
  ,p_action_information28         in varchar2
  ,p_action_information29         in varchar2
  ,p_action_information30         in varchar2
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
end pay_aif_rku;

/
