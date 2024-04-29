--------------------------------------------------------
--  DDL for Package OTA_FORUM_THREAD_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_FORUM_THREAD_BK3" as

-- ----------------------------------------------------------------------------
-- |---------------------< delete_forum_thread_b >-----------------------|
-- ----------------------------------------------------------------------------
procedure delete_forum_thread_b
  (p_forum_thread_id              in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_forum_thread_a >----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_forum_thread_a
  (p_forum_thread_id              in     number
  ,p_object_version_number         in     number
  );
--
end ota_forum_thread_bk3;

 

/
