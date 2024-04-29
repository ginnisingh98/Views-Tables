--------------------------------------------------------
--  DDL for Package OTA_FORUM_MESSAGE_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_FORUM_MESSAGE_BK1" as
--
-- ----------------------------------------------------------------------------
-- |-----------------< create_forum_message_b >-------------------------|
-- ----------------------------------------------------------------------------
procedure create_forum_message_b
  (p_effective_date               in  date
  ,p_forum_id                       in     number
  ,p_forum_thread_id                in     number
  ,p_business_group_id              in     number
  ,p_message_scope                  in     varchar2
  ,p_message_body                   in     varchar2
  ,p_parent_message_id              in     number
  ,p_person_id                      in     number
  ,p_contact_id                     in     number
  ,p_target_person_id               in     number
  ,p_target_contact_id              in     number
  ,p_object_version_number             in  number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------< create_forum_message_a >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_forum_message_a
  ( p_effective_date               in  date
  ,p_forum_id                       in     number
  ,p_forum_thread_id                in     number
  ,p_business_group_id              in     number
  ,p_message_scope                  in     varchar2
  ,p_message_body                   in     varchar2
  ,p_parent_message_id              in     number
  ,p_person_id                      in     number
  ,p_contact_id                     in     number
  ,p_target_person_id               in     number
  ,p_target_contact_id              in     number
  ,p_forum_message_id                  in  number
  ,p_object_version_number             in  number
  );

end ota_forum_message_bk1 ;

 

/
