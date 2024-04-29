--------------------------------------------------------
--  DDL for Package OTA_PVT_FRM_THREAD_USERS_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_PVT_FRM_THREAD_USERS_BK2" as
--
-- ----------------------------------------------------------------------------
-- |------------------< update_pvt_frm_thread_user_b >-------------------------|
-- ----------------------------------------------------------------------------
procedure update_pvt_frm_thread_user_b
  (
   p_effective_date               in  date
  ,p_forum_thread_id              in  number
  ,p_forum_id                     in number
  ,p_person_id                    in number
  ,p_contact_id                   in number
  ,p_business_group_id            in number
  ,p_author_person_id             in number
  ,p_author_contact_id            in number
  ,p_object_version_number        in  number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------< update_pvt_frm_thread_user_a >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_pvt_frm_thread_user_a
  (p_effective_date               in  date
  ,p_forum_thread_id              in  number
  ,p_forum_id                     in number
  ,p_person_id                    in number
  ,p_contact_id                   in number
  ,p_business_group_id            in number
  ,p_author_person_id             in number
  ,p_author_contact_id            in number
  ,p_object_version_number        in  number
  );
end ota_pvt_frm_thread_users_bk2 ;

 

/
