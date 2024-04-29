--------------------------------------------------------
--  DDL for Package OTA_CHAT_USER_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_CHAT_USER_BK3" as

-- ----------------------------------------------------------------------------
-- |---------------------< delete_chat_user_b >-----------------------|
-- ----------------------------------------------------------------------------
procedure delete_chat_user_b
  ( p_chat_id                      in     number
  ,p_person_id                    in  number
  ,p_contact_id                   in  number
  ,p_object_version_number        in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_chat_user_a >----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_chat_user_a
  ( p_chat_id                      in     number
  ,p_person_id                    in  number
  ,p_contact_id                   in  number
  ,p_object_version_number        in     number
  );
--
end ota_chat_user_bk3;

 

/
