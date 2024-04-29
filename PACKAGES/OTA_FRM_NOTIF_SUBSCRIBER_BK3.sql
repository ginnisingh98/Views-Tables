--------------------------------------------------------
--  DDL for Package OTA_FRM_NOTIF_SUBSCRIBER_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_FRM_NOTIF_SUBSCRIBER_BK3" as

-- ----------------------------------------------------------------------------
-- |---------------------< delete_frm_notif_subscriber_b >-----------------------|
-- ----------------------------------------------------------------------------
procedure delete_frm_notif_subscriber_b
  ( p_forum_id                             in     number
    ,p_person_id                            in     number
    ,p_contact_id                           in     number
    ,p_object_version_number                in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_frm_notif_subscriber_a >----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_frm_notif_subscriber_a
  ( p_forum_id                             in     number
  ,p_person_id                            in     number
  ,p_contact_id                           in     number
  ,p_object_version_number                in     number
  );
--
end ota_frm_notif_subscriber_bk3;

 

/
