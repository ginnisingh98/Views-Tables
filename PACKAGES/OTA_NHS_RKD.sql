--------------------------------------------------------
--  DDL for Package OTA_NHS_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_NHS_RKD" AUTHID CURRENT_USER as
/* $Header: otnhsrhi.pkh 120.0 2005/05/29 07:26:54 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_delete >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete(
   p_nota_history_id          in number
  ,p_person_id_o                 in number
  ,p_contact_id_o                in number
  ,p_trng_title_o             in varchar2
  ,p_provider_o                     in varchar2
  ,p_type_o                      in varchar2
  ,p_centre_o                    in varchar2
  ,p_completion_date_o           in date
  ,p_award_o                  in varchar2
  ,p_rating_o                    in varchar2
  ,p_duration_o                  in number
  ,p_duration_units_o               in varchar2
  ,p_activity_version_id_o          in number
  ,p_status_o                       in varchar2
  ,p_verified_by_id_o               in number
  ,p_nth_information_category_o     in varchar2
  ,p_nth_information1_o             in varchar2
  ,p_nth_information2_o             in varchar2
  ,p_nth_information3_o             in varchar2
  ,p_nth_information4_o             in varchar2
  ,p_nth_information5_o             in varchar2
  ,p_nth_information6_o             in varchar2
  ,p_nth_information7_o             in varchar2
  ,p_nth_information8_o             in varchar2
  ,p_nth_information9_o             in varchar2
  ,p_nth_information10_o            in varchar2
  ,p_nth_information11_o            in varchar2
  ,p_nth_information12_o            in varchar2
  ,p_nth_information13_o            in varchar2
  ,p_nth_information15_o            in varchar2
  ,p_nth_information16_o            in varchar2
  ,p_nth_information17_o            in varchar2
  ,p_nth_information18_o            in varchar2
  ,p_nth_information19_o            in varchar2
  ,p_nth_information20_o            in varchar2
  ,p_org_id_o                       in number
  ,p_object_version_number_o        in number
  ,p_business_group_id_o            in number
  ,p_nth_information14_o            in varchar2
  ,p_customer_id_o            in number
  ,p_organization_id_o           in number
  );
end ota_nhs_rkd;

 

/
