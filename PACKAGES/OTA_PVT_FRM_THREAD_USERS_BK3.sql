--------------------------------------------------------
--  DDL for Package OTA_PVT_FRM_THREAD_USERS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_PVT_FRM_THREAD_USERS_BK3" as

-- ----------------------------------------------------------------------------
-- |---------------------< delete_pvt_frm_thread_user_b >-----------------------|
-- ----------------------------------------------------------------------------
procedure delete_pvt_frm_thread_user_b
  (p_forum_thread_id               in     number
  ,p_forum_id                      in     number
  ,p_person_id                     in     number
  ,p_contact_id                    in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------< delete_pvt_frm_thread_user_a >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_pvt_frm_thread_user_a
  (p_forum_thread_id               in     number
  ,p_forum_id                      in     number
  ,p_person_id                     in     number
  ,p_contact_id                    in     number
  ,p_object_version_number         in     number
  );
--
end ota_pvt_frm_thread_users_bk3;

 

/
