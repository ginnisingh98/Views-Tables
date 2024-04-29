--------------------------------------------------------
--  DDL for Package PQH_RLS_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_RLS_RKD" AUTHID CURRENT_USER as
/* $Header: pqrlsrhi.pkh 120.0 2005/05/29 02:32:12 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
-- mvanakda
-- Passed Developer DF Columns to the procedure after_delete
procedure after_delete
  (p_role_id                      in number
  ,p_role_name_o                  in varchar2
  ,p_role_type_cd_o               in varchar2
  ,p_enable_flag_o                in varchar2
  ,p_object_version_number_o      in number
  ,p_business_group_id_o          in number
  ,p_information_category_o       in varchar2
  ,p_information1_o               in varchar2
  ,p_information2_o               in varchar2
  ,p_information3_o               in varchar2
  ,p_information4_o	          in varchar2
  ,p_information5_o               in varchar2
  ,p_information6_o	          in varchar2
  ,p_information7_o               in varchar2
  ,p_information8_o	          in varchar2
  ,p_information9_o               in varchar2
  ,p_information10_o	          in varchar2
  ,p_information11_o              in varchar2
  ,p_information12_o	          in varchar2
  ,p_information13_o	          in varchar2
  ,p_information14_o              in varchar2
  ,p_information15_o	          in varchar2
  ,p_information16_o              in varchar2
  ,p_information17_o	          in varchar2
  ,p_information18_o              in varchar2
  ,p_information19_o	          in varchar2
  ,p_information20_o              in varchar2
  ,p_information21_o              in varchar2
  ,p_information22_o	          in varchar2
  ,p_information23_o	          in varchar2
  ,p_information24_o              in varchar2
  ,p_information25_o	          in varchar2
  ,p_information26_o              in varchar2
  ,p_information27_o	          in varchar2
  ,p_information28_o              in varchar2
  ,p_information29_o	          in varchar2
  ,p_information30_o              in varchar2
  );
--
end pqh_rls_rkd;

 

/
