--------------------------------------------------------
--  DDL for Package OTA_CMS_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_CMS_RKI" AUTHID CURRENT_USER as
/* $Header: otcmsrhi.pkh 120.1 2005/09/14 00:39 pchandra noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_chat_message_id              in number
  ,p_chat_id                      in number
  ,p_business_group_id            in number
  ,p_person_id                    in number
  ,p_contact_id                   in number
  ,p_target_person_id             in number
  ,p_target_contact_id            in number
  ,p_message_text                 in varchar2
  ,p_object_version_number        in number
  );
end ota_cms_rki;

 

/