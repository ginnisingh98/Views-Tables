--------------------------------------------------------
--  DDL for Package PAY_PRT_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PRT_RKU" AUTHID CURRENT_USER as
/* $Header: pyprtrhi.pkh 120.0 2005/05/29 07:52:46 appldev noship $ */
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
  ,p_run_type_id                  in number
--  ,p_run_type_name                in varchar2
  ,p_effective_start_date         in date
  ,p_effective_end_date           in date
  ,p_shortname                    in varchar2
  ,p_srs_flag                     in varchar2
  ,p_run_information_category	  in varchar2
  ,p_run_information1		  in varchar2
  ,p_run_information2		  in varchar2
  ,p_run_information3		  in varchar2
  ,p_run_information4		  in varchar2
  ,p_run_information5		  in varchar2
  ,p_run_information6		  in varchar2
  ,p_run_information7		  in varchar2
  ,p_run_information8		  in varchar2
  ,p_run_information9		  in varchar2
  ,p_run_information10		  in varchar2
  ,p_run_information11		  in varchar2
  ,p_run_information12		  in varchar2
  ,p_run_information13		  in varchar2
  ,p_run_information14		  in varchar2
  ,p_run_information15		  in varchar2
  ,p_run_information16		  in varchar2
  ,p_run_information17		  in varchar2
  ,p_run_information18		  in varchar2
  ,p_run_information19		  in varchar2
  ,p_run_information20		  in varchar2
  ,p_run_information21		  in varchar2
  ,p_run_information22		  in varchar2
  ,p_run_information23		  in varchar2
  ,p_run_information24		  in varchar2
  ,p_run_information25		  in varchar2
  ,p_run_information26		  in varchar2
  ,p_run_information27		  in varchar2
  ,p_run_information28		  in varchar2
  ,p_run_information29		  in varchar2
  ,p_run_information30		  in varchar2
  ,p_object_version_number        in number
  ,p_run_type_name_o              in varchar2
  ,p_run_method_o                 in varchar2
  ,p_effective_start_date_o       in date
  ,p_effective_end_date_o         in date
  ,p_business_group_id_o          in number
  ,p_legislation_code_o           in varchar2
  ,p_shortname_o                  in varchar2
  ,p_srs_flag_o                   in varchar2
  ,p_run_information_category_o	  in varchar2
  ,p_run_information1_o		  in varchar2
  ,p_run_information2_o		  in varchar2
  ,p_run_information3_o		  in varchar2
  ,p_run_information4_o		  in varchar2
  ,p_run_information5_o		  in varchar2
  ,p_run_information6_o		  in varchar2
  ,p_run_information7_o		  in varchar2
  ,p_run_information8_o		  in varchar2
  ,p_run_information9_o		  in varchar2
  ,p_run_information10_o	  in varchar2
  ,p_run_information11_o	  in varchar2
  ,p_run_information12_o	  in varchar2
  ,p_run_information13_o	  in varchar2
  ,p_run_information14_o	  in varchar2
  ,p_run_information15_o	  in varchar2
  ,p_run_information16_o	  in varchar2
  ,p_run_information17_o	  in varchar2
  ,p_run_information18_o	  in varchar2
  ,p_run_information19_o	  in varchar2
  ,p_run_information20_o	  in varchar2
  ,p_run_information21_o	  in varchar2
  ,p_run_information22_o	  in varchar2
  ,p_run_information23_o	  in varchar2
  ,p_run_information24_o	  in varchar2
  ,p_run_information25_o	  in varchar2
  ,p_run_information26_o	  in varchar2
  ,p_run_information27_o	  in varchar2
  ,p_run_information28_o	  in varchar2
  ,p_run_information29_o	  in varchar2
  ,p_run_information30_o	  in varchar2
  ,p_object_version_number_o      in number
  );
--
end pay_prt_rku;

 

/
