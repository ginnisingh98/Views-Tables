--------------------------------------------------------
--  DDL for Package HR_FMP_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_FMP_RKD" AUTHID CURRENT_USER as
/* $Header: hrfmprhi.pkh 120.0 2005/05/31 00:25:24 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_form_property_id             in number
  ,p_object_version_number_o      in number
  ,p_application_id_o             in number
  ,p_form_id_o                    in number
  ,p_form_template_id_o           in number
  ,p_help_target_o                in varchar2
  ,p_information_category_o       in varchar2
  ,p_information1_o               in varchar2
  ,p_information2_o               in varchar2
  ,p_information3_o               in varchar2
  ,p_information4_o               in varchar2
  ,p_information5_o               in varchar2
  ,p_information6_o               in varchar2
  ,p_information7_o               in varchar2
  ,p_information8_o               in varchar2
  ,p_information9_o               in varchar2
  ,p_information10_o              in varchar2
  ,p_information11_o              in varchar2
  ,p_information12_o              in varchar2
  ,p_information13_o              in varchar2
  ,p_information14_o              in varchar2
  ,p_information15_o              in varchar2
  ,p_information16_o              in varchar2
  ,p_information17_o              in varchar2
  ,p_information18_o              in varchar2
  ,p_information19_o              in varchar2
  ,p_information20_o              in varchar2
  ,p_information21_o              in varchar2
  ,p_information22_o              in varchar2
  ,p_information23_o              in varchar2
  ,p_information24_o              in varchar2
  ,p_information25_o              in varchar2
  ,p_information26_o              in varchar2
  ,p_information27_o              in varchar2
  ,p_information28_o              in varchar2
  ,p_information29_o              in varchar2
  ,p_information30_o              in varchar2
  );
--
end hr_fmp_rkd;

 

/
