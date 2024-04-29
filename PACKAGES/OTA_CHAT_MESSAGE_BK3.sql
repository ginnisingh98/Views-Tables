--------------------------------------------------------
--  DDL for Package OTA_CHAT_MESSAGE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_CHAT_MESSAGE_BK3" as

-- ----------------------------------------------------------------------------
-- |---------------------< delete_chat_message_b >-----------------------|
-- ----------------------------------------------------------------------------
procedure delete_chat_message_b
  (p_chat_message_id                      in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_chat_message_a >----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_chat_message_a
  ( p_chat_message_id                      in     number
  ,p_object_version_number         in     number
  );
--
end ota_chat_message_bk3;

 

/
