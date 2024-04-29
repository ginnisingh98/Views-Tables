--------------------------------------------------------
--  DDL for Package OTA_FRM_NOTIF_SUBSCRIBER_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_FRM_NOTIF_SUBSCRIBER_BK2" as
-- ----------------------------------------------------------------------------
-- |----------------< update_frm_notif_subscriber_b >----------------------------|
-- ----------------------------------------------------------------------------
procedure update_frm_notif_subscriber_b
   (p_effective_date               in     date
  ,p_forum_id                     in     number
  ,p_person_id                    in     number
  ,p_contact_id                   in     number
  ,p_object_version_number        in   number
  ,p_business_group_id            in     number
  );

--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_frm_notif_subscriber_a >-------------------|
-- ----------------------------------------------------------------------------
--
procedure update_frm_notif_subscriber_a
   (p_effective_date               in     date
  ,p_forum_id                     in     number
  ,p_person_id                    in     number
  ,p_contact_id                   in     number
  ,p_object_version_number        in   number
  ,p_business_group_id            in     number
  );


end ota_frm_notif_subscriber_bk2;

 

/
