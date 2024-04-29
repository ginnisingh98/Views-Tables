--------------------------------------------------------
--  DDL for Package OTA_CMS_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_CMS_RKD" AUTHID CURRENT_USER as
/* $Header: otcmsrhi.pkh 120.1 2005/09/14 00:39 pchandra noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_chat_message_id              in number
  ,p_chat_id_o                    in number
  ,p_business_group_id_o          in number
  ,p_person_id_o                  in number
  ,p_contact_id_o                 in number
  ,p_target_person_id_o           in number
  ,p_target_contact_id_o          in number
  ,p_message_text_o               in varchar2
  ,p_object_version_number_o      in number
  );
--
end ota_cms_rkd;

 

/
