--------------------------------------------------------
--  DDL for Package OTA_FORUM_MESSAGE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_FORUM_MESSAGE_BK3" as

-- ----------------------------------------------------------------------------
-- |---------------------< delete_forum_message_b >-----------------------|
-- ----------------------------------------------------------------------------
procedure delete_forum_message_b
  (p_forum_message_id              in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_forum_message_a >----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_forum_message_a
  (p_forum_message_id              in     number
  ,p_object_version_number         in     number
  );
--
end ota_forum_message_bk3;

 

/
