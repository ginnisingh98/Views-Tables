--------------------------------------------------------
--  DDL for Package PAY_PRT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PRT_RKD" AUTHID CURRENT_USER as
/* $Header: pyprtrhi.pkh 120.0 2005/05/29 07:52:46 appldev noship $ */
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
  ,p_run_type_id                  in number
  ,p_effective_start_date         in date
  ,p_effective_end_date           in date
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
end pay_prt_rkd;

 

/
