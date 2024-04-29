--------------------------------------------------------
--  DDL for Package OTA_FMS_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_FMS_RKI" AUTHID CURRENT_USER as
/* $Header: otfmsrhi.pkh 120.0 2005/06/24 07:54 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_forum_message_id             in number
  ,p_forum_id                     in number
  ,p_forum_thread_id              in number
  ,p_business_group_id            in number
  ,p_message_body                 in varchar2
  ,p_parent_message_id            in number
  ,p_person_id                    in number
  ,p_contact_id                   in number
  ,p_target_person_id             in number
  ,p_target_contact_id            in number
  ,p_message_scope                in varchar2
  ,p_object_version_number        in number
  );
end ota_fms_rki;

 

/
