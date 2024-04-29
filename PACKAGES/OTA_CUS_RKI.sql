--------------------------------------------------------
--  DDL for Package OTA_CUS_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_CUS_RKI" AUTHID CURRENT_USER as
/* $Header: otcusrhi.pkh 120.0 2005/06/24 07:53 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_chat_id                      in number
  ,p_business_group_id            in number
  ,p_person_id                    in number
  ,p_contact_id                   in number
  ,p_login_date                   in date
  ,p_object_version_number        in number
  );
end ota_cus_rki;

 

/
