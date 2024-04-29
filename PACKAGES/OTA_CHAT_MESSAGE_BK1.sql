--------------------------------------------------------
--  DDL for Package OTA_CHAT_MESSAGE_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_CHAT_MESSAGE_BK1" as
--
-- ----------------------------------------------------------------------------
-- |-----------------< create_chat_message_b >-------------------------|
-- ----------------------------------------------------------------------------
procedure create_chat_message_b
  ( p_effective_date               in  date
  ,p_chat_id                      in  number
  ,p_person_id                    in  number
  ,p_contact_id                   in  number
  ,p_target_person_id             in  number
  ,p_target_contact_id            in  number
  ,p_message_text                 in  varchar2
  ,p_business_group_id            in  number
  ,p_object_version_number        in  number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------< create_chat_message_a >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_chat_message_a
  ( p_effective_date               in  date
  ,p_chat_id                      in  number
  ,p_person_id                    in  number
  ,p_contact_id                   in  number
  ,p_target_person_id             in  number
  ,p_target_contact_id            in  number
  ,p_message_text                 in  varchar2
  ,p_business_group_id            in  number
  ,p_chat_message_id              in  number
  ,p_object_version_number        in  number
  );

end ota_chat_message_bk1 ;

 

/
