--------------------------------------------------------
--  DDL for Package OTA_NHS_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_NHS_RKI" AUTHID CURRENT_USER as
/* $Header: otnhsrhi.pkh 120.0 2005/05/29 07:26:54 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date           in date
  ,p_nota_history_id             in number
  ,p_person_id             in number
  ,p_contact_id               in number
  ,p_trng_title            in varchar2
  ,p_provider                    in varchar2
  ,p_type                  in varchar2
  ,p_centre                   in varchar2
  ,p_completion_date          in date
  ,p_award                    in varchar2
  ,p_rating                   in varchar2
  ,p_duration              in number
  ,p_duration_units              in varchar2
  ,p_activity_version_id         in number
  ,p_status                      in varchar2
  ,p_verified_by_id               in number
  ,p_nth_information_category     in varchar2
  ,p_nth_information1             in varchar2
  ,p_nth_information2             in varchar2
  ,p_nth_information3             in varchar2
  ,p_nth_information4             in varchar2
  ,p_nth_information5             in varchar2
  ,p_nth_information6             in varchar2
  ,p_nth_information7             in varchar2
  ,p_nth_information8             in varchar2
  ,p_nth_information9             in varchar2
  ,p_nth_information10            in varchar2
  ,p_nth_information11            in varchar2
  ,p_nth_information12            in varchar2
  ,p_nth_information13            in varchar2
  ,p_nth_information15            in varchar2
  ,p_nth_information16            in varchar2
  ,p_nth_information17            in varchar2
  ,p_nth_information18            in varchar2
  ,p_nth_information19            in varchar2
  ,p_nth_information20            in varchar2
  ,p_org_id                       in number
  ,p_object_version_number        in number
  ,p_business_group_id            in number
  ,p_nth_information14            in varchar2
  ,p_customer_id         in number
  ,p_organization_id     in number
  );
end ota_nhs_rki;

 

/
