--------------------------------------------------------
--  DDL for Package OTA_FORUM_THREAD_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_FORUM_THREAD_BK2" as
--
-- ----------------------------------------------------------------------------
-- |-----------------< update_forum_thread_b >-------------------------|
-- ----------------------------------------------------------------------------
procedure update_forum_thread_b
  (p_effective_date                 in  date
  ,p_forum_id                       in     number
  ,p_business_group_id              in     number
  ,p_subject                        in     varchar2
  ,p_private_thread_flag            in     varchar2
  ,p_last_post_date                 in     date
  ,p_reply_count                    in     number
  ,p_forum_thread_id                in  number
  ,p_object_version_number          in  number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------< update_forum_thread_a >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_forum_thread_a
  ( p_effective_date                 in  date
  ,p_forum_id                       in     number
  ,p_business_group_id              in     number
  ,p_subject                        in     varchar2
  ,p_private_thread_flag            in     varchar2
  ,p_last_post_date                 in     date
  ,p_reply_count                    in     number
  ,p_forum_thread_id                in  number
  ,p_object_version_number          in  number
  );

end ota_forum_thread_bk2 ;

 

/
