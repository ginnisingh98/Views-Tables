--------------------------------------------------------
--  DDL for Package OTA_CUS_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_CUS_RKU" AUTHID CURRENT_USER as
/* $Header: otcusrhi.pkh 120.0 2005/06/24 07:53 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_effective_date               in date
  ,p_chat_id                      in number
  ,p_business_group_id            in number
  ,p_person_id                    in number
  ,p_contact_id                   in number
  ,p_login_date                   in date
  ,p_object_version_number        in number
  ,p_business_group_id_o          in number
  ,p_login_date_o                 in date
  ,p_object_version_number_o      in number
  );
--
end ota_cus_rku;

 

/
