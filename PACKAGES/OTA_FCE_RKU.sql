--------------------------------------------------------
--  DDL for Package OTA_FCE_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_FCE_RKU" AUTHID CURRENT_USER as
/* $Header: otfcerhi.pkh 120.0 2005/06/24 07:54 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_effective_date               in date
  ,p_enrollment_id                in number
  ,p_forum_id                     in number
  ,p_business_group_id            in number
  ,p_person_id                    in number
  ,p_contact_id                   in number
  ,p_object_version_number        in number
  ,p_chat_id                      in number
  ,p_forum_id_o                   in number
  ,p_business_group_id_o          in number
  ,p_person_id_o                  in number
  ,p_contact_id_o                 in number
  ,p_object_version_number_o      in number
  ,p_chat_id_o                    in number
  );
--
end ota_fce_rku;

 

/
