--------------------------------------------------------
--  DDL for Package OTA_FCE_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_FCE_RKD" AUTHID CURRENT_USER as
/* $Header: otfcerhi.pkh 120.0 2005/06/24 07:54 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_enrollment_id                in number
  ,p_forum_id_o                   in number
  ,p_business_group_id_o          in number
  ,p_person_id_o                  in number
  ,p_contact_id_o                 in number
  ,p_object_version_number_o      in number
  ,p_chat_id_o                    in number
  );
--
end ota_fce_rkd;

 

/
